import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prayer_alarm/core/result.dart';
import 'package:prayer_alarm/prayer_times/aladhan_client.dart';
import 'package:prayer_alarm/prayer_times/aladhan_parser.dart';
import 'package:prayer_alarm/prayer_times/calculation_method.dart';
import 'package:prayer_alarm/prayer_times/geo_point.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';
import 'package:prayer_alarm/prayer_times/wall_time.dart';

import '../support/aladhan_fixtures.dart';
import '../support/tz_zone_rules.dart';

const _nyc = GeoPoint(40.7128, -74.006);

void main() {
  final fixtures = AlAdhanFixtures();
  final sample = File(
    'test/fixtures/aladhan/calendar_nyc_2026_03_07_08.json',
  ).readAsStringSync();

  late List<http.Request> requests;

  AlAdhanClient clientReplying(
    List<Future<http.Response> Function()> replies, {
    Duration timeout = const Duration(seconds: 8),
  }) {
    requests = [];
    var call = 0;
    return AlAdhanClient(
      httpClient: MockClient((request) {
        requests.add(request);
        final reply = replies[call < replies.length ? call : replies.length - 1];
        call++;
        return reply();
      }),
      timeout: timeout,
      retryDelay: Duration.zero,
      zoneRulesFor: (zone) => TzZoneRules(zone ?? 'America/New_York'),
    );
  }

  // UTF-8 bytes like the real server sends (the sample has Arabic text,
  // which http.Response(String) would try to encode as Latin-1).
  http.Response utf8Response(String body, int code) => http.Response.bytes(
    utf8.encode(body),
    code,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
  Future<http.Response> Function() ok(String body) =>
      () async => utf8Response(body, 200);
  Future<http.Response> Function() status(int code, [String body = '']) =>
      () async => utf8Response(body, code);

  Future<Result<AlAdhanMonth, AlAdhanFailure>> fetch(AlAdhanClient client) =>
      client.fetchMonth(
        year: 2026,
        month: 3,
        location: _nyc,
        method: CalculationMethods.isna,
      );

  group('success', () {
    test('parses ISO times into exact instants across spring-forward', () async {
      final client = clientReplying([ok(sample)]);

      final month = switch (await fetch(client)) {
        Ok(:final value) => value,
        Err(:final error) => fail('unexpected $error'),
      };

      expect(month.timeZone, 'America/New_York');
      expect(month.days, hasLength(2));
      final sat = month.days[0].times[Prayer.fajr]!;
      final sun = month.days[1].times[Prayer.fajr]!;
      // 05:58 EST and 06:56 EDT: wall clock jumps, instants stay exact.
      expect(sat.at, DateTime.utc(2026, 3, 7, 10, 58));
      expect(sat.wall, const WallTime(5, 58));
      expect(sun.at, DateTime.utc(2026, 3, 8, 10, 56));
      expect(sun.wall, const WallTime(6, 56));
      expect(month.days[1].times.keys, Prayer.values);
    });

    test('sends coordinates, explicit method and school, and iso8601', () async {
      final client = clientReplying([ok(sample)]);

      await fetch(client);

      final uri = requests.single.url;
      expect(uri.path, '/v1/calendar/2026/3');
      expect(uri.queryParameters, {
        'latitude': '40.7128',
        'longitude': '-74.006',
        'method': '2',
        'school': '0',
        'iso8601': 'true',
      });
      expect(requests.single.headers['User-Agent'], startsWith('PrayerAlarm/'));
    });

    test('accepts the plain "HH:mm (EST)" format', () async {
      final client = clientReplying([
        ok(AlAdhanFixtures.body([fixtures.entry(2026, 3, 7, isoFormat: false)])),
      ]);

      final month = (await fetch(client) as Ok<AlAdhanMonth, AlAdhanFailure>)
          .value;

      final fajr = month.days.single.times[Prayer.fajr]!;
      expect(fajr.wall, const WallTime(5, 30));
      expect(fajr.at, DateTime.utc(2026, 3, 7, 10, 30));
    });
  });

  group('rate limited', () {
    test('429 then success: retries once and succeeds', () async {
      final client = clientReplying([status(429, 'Too Many Requests'), ok(sample)]);

      expect(await fetch(client), isA<Ok<AlAdhanMonth, AlAdhanFailure>>());
      expect(requests, hasLength(2));
    });

    test('429 twice: gives up after one retry', () async {
      final client = clientReplying([status(429)]);

      final result = await fetch(client);

      expect((result as Err).error, isA<AlAdhanRateLimited>());
      expect(requests, hasLength(2));
    });
  });

  group('timeout', () {
    Future<http.Response> Function() hang() => () => Future.delayed(
      const Duration(milliseconds: 300),
      () => utf8Response(sample, 200),
    );

    test('times out twice: AlAdhanTimeout after one retry', () async {
      final client = clientReplying([
        hang(),
      ], timeout: const Duration(milliseconds: 20));

      final result = await fetch(client);

      expect((result as Err).error, isA<AlAdhanTimeout>());
      expect(requests, hasLength(2));
    });

    test('times out then answers: succeeds on the retry', () async {
      final client = clientReplying([
        hang(),
        ok(sample),
      ], timeout: const Duration(milliseconds: 20));

      expect(await fetch(client), isA<Ok<AlAdhanMonth, AlAdhanFailure>>());
    });
  });

  test('network error is retried once, then reported', () async {
    final client = clientReplying([
      () async => throw http.ClientException('Connection refused'),
    ]);

    final result = await fetch(client);

    expect((result as Err).error, isA<AlAdhanNetworkError>());
    expect(requests, hasLength(2));
  });

  test('server error 500 then 503: retried once, reports the last status', () async {
    final client = clientReplying([status(500), status(503)]);

    final error = (await fetch(client) as Err).error;

    expect(error, isA<AlAdhanServerError>());
    expect((error as AlAdhanServerError).statusCode, 503);
    expect(requests, hasLength(2));
  });

  test('400 is not retried and keeps the API message', () async {
    final client = clientReplying([
      status(400, '{"code":400,"status":"BAD_REQUEST","data":"Please specify a valid latitude."}'),
    ]);

    final error = (await fetch(client) as Err).error;

    expect(error, isA<AlAdhanRejected>());
    expect((error as AlAdhanRejected).message, 'Please specify a valid latitude.');
    expect(requests, hasLength(1));
  });

  group('malformed responses (never retried)', () {
    Future<AlAdhanFailure> failureFor(String body) async {
      final client = clientReplying([ok(body)]);
      final error = (await fetch(client) as Err).error as AlAdhanFailure;
      expect(requests, hasLength(1));
      return error;
    }

    test('HTML page with status 200', () async {
      expect(
        await failureFor('<html><body>Sign in to Wi-Fi</body></html>'),
        isA<AlAdhanMalformed>(),
      );
    });

    test('JSON of the wrong shape', () async {
      expect(await failureFor('{"code":200,"data":"oops"}'), isA<AlAdhanMalformed>());
      expect(await failureFor('[1,2,3]'), isA<AlAdhanMalformed>());
      expect(await failureFor('{"code":200,"data":[]}'), isA<AlAdhanMalformed>());
    });

    test('non-200 code inside the body', () async {
      expect(
        await failureFor('{"code":500,"status":"ERROR","data":[]}'),
        isA<AlAdhanMalformed>(),
      );
    });

    test('every day unusable', () async {
      final bad = fixtures.entry(2026, 3, 7)..['timings'] = {'Fajr': 'soon'};
      expect(await failureFor(AlAdhanFixtures.body([bad])), isA<AlAdhanMalformed>());
    });
  });

  group('partially bad data', () {
    Future<AlAdhanMonth> monthFor(List<Map<String, Object?>> entries) async {
      final client = clientReplying([ok(AlAdhanFixtures.body(entries))]);
      return (await fetch(client) as Ok<AlAdhanMonth, AlAdhanFailure>).value;
    }

    test('a day with a missing or garbled prayer is skipped, not guessed', () async {
      final missing = fixtures.entry(2026, 3, 7);
      (missing['timings'] as Map).remove('Isha');
      final garbled = fixtures.entry(2026, 3, 8);
      (garbled['timings'] as Map)['Asr'] = '25:99';
      final good = fixtures.entry(2026, 3, 9);

      final month = await monthFor([missing, garbled, good]);

      expect(month.days.map((d) => d.date), [DateTime.utc(2026, 3, 9)]);
    });

    test('ISO time without an offset is refused', () async {
      final noOffset = fixtures.entry(2026, 3, 7);
      (noOffset['timings'] as Map)['Fajr'] = '2026-03-07T05:58:00';

      final month = await monthFor([noOffset, fixtures.entry(2026, 3, 8)]);

      expect(month.days.map((d) => d.date), [DateTime.utc(2026, 3, 8)]);
    });

    test('impossible dates are skipped', () async {
      final impossible = fixtures.entry(2026, 3, 7);
      ((impossible['date'] as Map)['gregorian'] as Map)['date'] = '31-02-2026';

      final month = await monthFor([impossible, fixtures.entry(2026, 3, 8)]);

      expect(month.days.map((d) => d.date), [DateTime.utc(2026, 3, 8)]);
    });
  });
}
