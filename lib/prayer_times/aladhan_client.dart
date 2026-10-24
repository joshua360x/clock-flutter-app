import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/result.dart';
import 'aladhan_parser.dart';
import 'calculation_method.dart';
import 'geo_point.dart';
import 'zone_rules.dart';

/// Why an AlAdhan request produced no timetable.
sealed class AlAdhanFailure {
  const AlAdhanFailure();

  /// Worth one more try: the same request may succeed a moment later.
  bool get isTransient => false;
}

final class AlAdhanTimeout extends AlAdhanFailure {
  const AlAdhanTimeout();

  @override
  bool get isTransient => true;
}

final class AlAdhanNetworkError extends AlAdhanFailure {
  const AlAdhanNetworkError(this.cause);
  final Object cause;

  @override
  bool get isTransient => true;
}

/// 429. AlAdhan limits per second (~12 req/s per IP), so a short wait helps.
final class AlAdhanRateLimited extends AlAdhanFailure {
  const AlAdhanRateLimited();

  @override
  bool get isTransient => true;
}

final class AlAdhanServerError extends AlAdhanFailure {
  const AlAdhanServerError(this.statusCode);
  final int statusCode;

  @override
  bool get isTransient => true;
}

/// Any other 4xx, e.g. 400 for invalid coordinates. Retrying cannot help.
final class AlAdhanRejected extends AlAdhanFailure {
  const AlAdhanRejected(this.statusCode, this.message);
  final int statusCode;
  final String? message;
}

/// 200 with a body that is not a usable calendar (captive portal page,
/// changed schema, every day unparseable).
final class AlAdhanMalformed extends AlAdhanFailure {
  const AlAdhanMalformed(this.reason);
  final String reason;
}

/// Fetches monthly prayer-time calendars from https://api.aladhan.com.
class AlAdhanClient {
  AlAdhanClient({
    required http.Client httpClient,
    this.baseUrl = 'https://api.aladhan.com/v1',
    this.timeout = const Duration(seconds: 8),
    this.retryDelay = const Duration(seconds: 1),
    this.zoneRulesFor = deviceZoneRulesFor,
  }) : _http = httpClient;

  final http.Client _http;
  final String baseUrl;
  final Duration timeout;
  final Duration retryDelay;
  final ZoneRulesFactory zoneRulesFor;

  static const _maxAttempts = 2;
  static const _headers = {
    'Accept': 'application/json',
    'User-Agent':
        'PrayerAlarm/1.0 (+https://github.com/joshua360x/clock-flutter-app)',
  };

  /// One Gregorian month of times for [location]. Method and school are
  /// always sent explicitly so the times cannot shift if AlAdhan changes its
  /// defaults.
  Future<Result<AlAdhanMonth, AlAdhanFailure>> fetchMonth({
    required int year,
    required int month,
    required GeoPoint location,
    required CalculationMethod method,
    AsrSchool school = AsrSchool.standard,
  }) async {
    final uri = Uri.parse('$baseUrl/calendar/$year/$month').replace(
      queryParameters: {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'method': '${method.id}',
        'school': '${school.apiValue}',
        'iso8601': 'true',
      },
    );

    for (var attempt = 1; ; attempt++) {
      final result = await _attempt(uri);
      if (result case Err(error: final failure)
          when failure.isTransient && attempt < _maxAttempts) {
        await Future<void>.delayed(retryDelay);
        continue;
      }
      return result;
    }
  }

  Future<Result<AlAdhanMonth, AlAdhanFailure>> _attempt(Uri uri) async {
    final http.Response response;
    try {
      response = await _http.get(uri, headers: _headers).timeout(timeout);
    } on TimeoutException {
      return const Err(AlAdhanTimeout());
    } on Exception catch (e) {
      return Err(AlAdhanNetworkError(e));
    }

    final status = response.statusCode;
    if (status == 429) return const Err(AlAdhanRateLimited());
    if (status >= 500) return Err(AlAdhanServerError(status));

    // Decode as UTF-8 regardless of headers; non-JSON bodies are expected
    // from proxies, captive portals and error pages.
    final Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
    } on FormatException {
      return status == 200
          ? const Err(AlAdhanMalformed('body is not JSON'))
          : Err(AlAdhanRejected(status, null));
    }

    if (status != 200) {
      final message = body is Map && body['data'] is String
          ? body['data'] as String
          : null;
      return Err(AlAdhanRejected(status, message));
    }
    try {
      return Ok(parseAlAdhanCalendar(body, zoneRulesFor: zoneRulesFor));
    } on FormatException catch (e) {
      return Err(AlAdhanMalformed(e.message));
    }
  }
}
