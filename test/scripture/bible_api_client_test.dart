import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prayer_alarm/core/result.dart';
import 'package:prayer_alarm/scripture/bible_api_client.dart';
import 'package:prayer_alarm/scripture/verse.dart';

/// Response shapes come from bible-api's server code (seven1m/bible_api
/// app.rb): the two endpoints differ, and errors are often plain text.
void main() {
  final reference = File(
    'test/fixtures/bible_api/reference_john_3_16_kjv.json',
  ).readAsStringSync();
  final random = File(
    'test/fixtures/bible_api/random_nt_kjv.json',
  ).readAsStringSync();

  late List<http.Request> requests;

  BibleApiClient clientReplying(
    List<Future<http.Response> Function()> replies, {
    Duration timeout = const Duration(seconds: 4),
  }) {
    requests = [];
    var call = 0;
    return BibleApiClient(
      httpClient: MockClient((request) {
        requests.add(request);
        final reply = replies[call < replies.length ? call : replies.length - 1];
        call++;
        return reply();
      }),
      timeout: timeout,
      retryDelay: Duration.zero,
    );
  }

  Future<http.Response> Function() reply(
    int status,
    String body, {
    String type = 'application/json; charset=utf-8',
    Map<String, String> headers = const {},
  }) =>
      () async => http.Response.bytes(
        utf8.encode(body),
        status,
        headers: {'content-type': type, ...headers},
      );

  Verse okVerse(Result<Verse, BibleApiFailure> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final error) => fail('unexpected $error'),
  };

  BibleApiFailure failure(Result<Verse, BibleApiFailure> result) =>
      switch (result) {
        Ok(:final value) => fail('unexpected $value'),
        Err(:final error) => error,
      };

  group('success', () {
    test('specific verse: reference shape, whitespace normalised', () async {
      final client = clientReplying([reply(200, reference)]);

      final verse = okVerse(await client.fetchReference('John 3:16'));

      expect(verse.reference, 'John 3:16');
      expect(verse.text, fallbackVerse.text);
      expect(requests.single.url.toString(), 'https://bible-api.com/John+3:16?translation=kjv');
    });

    test('multi-word book and verse ranges build the expected path', () async {
      final client = clientReplying([reply(200, reference)]);

      await client.fetchReference('1 Corinthians 16:13-14');

      expect(requests.single.url.path, '/1+Corinthians+16:13-14');
      expect(requests.single.url.queryParameters, {'translation': 'kjv'});
    });

    test('random verse: nested shape with no reference field', () async {
      final client = clientReplying([reply(200, random)]);

      final verse = okVerse(await client.fetchRandom());

      expect(verse.reference, 'Romans 8:28');
      expect(verse.text, startsWith('And we know that all things'));
      expect(verse.text, isNot(endsWith('\n')));
      expect(requests.single.url.path, '/data/kjv/random/NT');
    });

    test('random verse tolerates numbers sent as strings', () async {
      final client = clientReplying([
        reply(200, jsonEncode({
          'random_verse': {'book': 'John', 'chapter': '14', 'verse': '27', 'text': 'Peace I leave with you'},
        })),
      ]);

      expect(okVerse(await client.fetchRandom()).reference, 'John 14:27');
    });

    test('reference shape with empty top-level text falls back to verses', () async {
      final client = clientReplying([
        reply(200, jsonEncode({
          'reference': 'Romans 8:38-39',
          'text': '',
          'verses': [
            {'text': 'For I am persuaded,\n'},
            {'text': '\nNor height, nor depth.'},
          ],
        })),
      ]);

      expect(
        okVerse(await client.fetchReference('Romans 8:38-39')).text,
        'For I am persuaded, Nor height, nor depth.',
      );
    });
  });

  group('rate limited', () {
    test('429 plain-text body: reported, not retried', () async {
      final client = clientReplying([
        reply(429, 'Retry later\n', type: 'text/plain'),
      ]);

      final error = failure(await client.fetchReference('John 3:16'));

      expect(error, isA<BibleApiRateLimited>());
      expect((error as BibleApiRateLimited).retryAfter, isNull);
      expect(requests, hasLength(1));
    });

    test('Retry-After header is passed on when present', () async {
      final client = clientReplying([
        reply(429, 'Retry later\n', type: 'text/plain', headers: {'retry-after': '17'}),
      ]);

      final error = failure(await client.fetchReference('John 3:16'));

      expect((error as BibleApiRateLimited).retryAfter, const Duration(seconds: 17));
    });

    test('403 (IP blocked after repeated 404s): reported, not retried', () async {
      final client = clientReplying([reply(403, 'Forbidden\n', type: 'text/plain')]);

      expect(failure(await client.fetchReference('John 3:16')), isA<BibleApiBlocked>());
      expect(requests, hasLength(1));
    });

    test('404 is never retried, so it cannot add to the abuse count', () async {
      final client = clientReplying([reply(404, '{"error":"not found"}')]);

      expect(failure(await client.fetchReference('Hezekiah 1:1')), isA<BibleApiNotFound>());
      expect(requests, hasLength(1));
    });
  });

  group('timeout', () {
    Future<http.Response> Function() hang() => () => Future.delayed(
      const Duration(milliseconds: 300),
      () => http.Response(reference, 200),
    );

    test('times out twice: one retry, then BibleApiTimeout', () async {
      final client = clientReplying([hang()], timeout: const Duration(milliseconds: 20));

      expect(failure(await client.fetchReference('John 3:16')), isA<BibleApiTimeout>());
      expect(requests, hasLength(2));
    });

    test('times out, then answers: the retry succeeds', () async {
      final client = clientReplying(
        [hang(), reply(200, reference)],
        timeout: const Duration(milliseconds: 20),
      );

      expect(okVerse(await client.fetchReference('John 3:16')).reference, 'John 3:16');
    });
  });

  test('server error is retried once', () async {
    final client = clientReplying([
      reply(502, '<html>Bad Gateway</html>', type: 'text/html'),
      reply(200, reference),
    ]);

    expect(await client.fetchReference('John 3:16'), isA<Ok<Verse, BibleApiFailure>>());
    expect(requests, hasLength(2));
  });

  test('network error is retried once, then reported', () async {
    final client = clientReplying([
      () async => throw http.ClientException('Failed host lookup'),
    ]);

    expect(failure(await client.fetchReference('John 3:16')), isA<BibleApiNetworkError>());
    expect(requests, hasLength(2));
  });

  group('malformed responses (never retried)', () {
    Future<BibleApiFailure> referenceFailure(String body) async {
      final client = clientReplying([reply(200, body)]);
      final error = failure(await client.fetchReference('John 3:16'));
      expect(requests, hasLength(1));
      return error;
    }

    Future<BibleApiFailure> randomFailure(String body) async {
      final client = clientReplying([reply(200, body)]);
      final error = failure(await client.fetchRandom());
      expect(requests, hasLength(1));
      return error;
    }

    test('HTML with status 200 (captive portal)', () async {
      expect(await referenceFailure('<html>Log in to Wi-Fi</html>'), isA<BibleApiMalformed>());
    });

    test('valid JSON, wrong shape', () async {
      expect(await referenceFailure('[]'), isA<BibleApiMalformed>());
      expect(await referenceFailure('{"text":"no reference"}'), isA<BibleApiMalformed>());
      expect(await referenceFailure('{"reference":"John 3:16","text":42}'), isA<BibleApiMalformed>());
    });

    test('text that is only whitespace', () async {
      expect(
        await referenceFailure('{"reference":"John 3:16","text":"\\n\\n  "}'),
        isA<BibleApiMalformed>(),
      );
    });

    test('random shape with missing or invalid fields', () async {
      expect(await randomFailure('{"verse":{}}'), isA<BibleApiMalformed>());
      expect(
        await randomFailure('{"random_verse":{"book":"John","chapter":0,"verse":1,"text":"x"}}'),
        isA<BibleApiMalformed>(),
      );
      expect(
        await randomFailure('{"random_verse":{"book":"John","chapter":3,"verse":16}}'),
        isA<BibleApiMalformed>(),
      );
    });

    test('the reference shape is not accepted by the random parser', () async {
      expect(await randomFailure(reference), isA<BibleApiMalformed>());
    });
  });
}
