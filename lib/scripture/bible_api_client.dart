import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/result.dart';
import 'verse.dart';

/// Why bible-api.com produced no verse.
sealed class BibleApiFailure {
  const BibleApiFailure();

  /// Worth one more try a moment later. 429/403/404 are deliberately not:
  /// the rate limit is a 30-second window, and repeated 404s get the IP
  /// blocked for an hour.
  bool get isTransient => false;
}

final class BibleApiTimeout extends BibleApiFailure {
  const BibleApiTimeout();

  @override
  bool get isTransient => true;
}

final class BibleApiNetworkError extends BibleApiFailure {
  const BibleApiNetworkError(this.cause);
  final Object cause;

  @override
  bool get isTransient => true;
}

final class BibleApiServerError extends BibleApiFailure {
  const BibleApiServerError(this.statusCode);
  final int statusCode;

  @override
  bool get isTransient => true;
}

/// 429: more than 15 requests in 30 s from this IP (carrier NAT can share an
/// IP with many phones). The body is plain text, not JSON.
final class BibleApiRateLimited extends BibleApiFailure {
  const BibleApiRateLimited({this.retryAfter});
  final Duration? retryAfter;
}

/// 403: the IP is blocked, typically for an hour after too many 404s.
final class BibleApiBlocked extends BibleApiFailure {
  const BibleApiBlocked();
}

/// 404: the reference does not exist in this translation.
final class BibleApiNotFound extends BibleApiFailure {
  const BibleApiNotFound();
}

/// Any other 4xx.
final class BibleApiRejected extends BibleApiFailure {
  const BibleApiRejected(this.statusCode);
  final int statusCode;
}

/// 200 with a body that is not a usable verse.
final class BibleApiMalformed extends BibleApiFailure {
  const BibleApiMalformed(this.reason);
  final String reason;
}

/// Client for https://bible-api.com (hobby server, no uptime guarantee).
class BibleApiClient {
  BibleApiClient({
    required http.Client httpClient,
    this.baseUrl = 'https://bible-api.com',
    this.translation = ScriptureTranslation.id,
    this.timeout = const Duration(seconds: 4),
    this.retryDelay = const Duration(milliseconds: 1500),
  }) : _http = httpClient;

  final http.Client _http;
  final String baseUrl;
  final String translation;
  final Duration timeout;
  final Duration retryDelay;

  static const _maxAttempts = 2;
  static const _headers = {
    'Accept': 'application/json',
    'User-Agent':
        'PrayerAlarm/1.0 (+https://github.com/joshua360x/clock-flutter-app)',
  };

  /// A specific passage, e.g. "John 3:16" or "Romans 8:38-39":
  /// `GET /john+3:16?translation=kjv`.
  Future<Result<Verse, BibleApiFailure>> fetchReference(String reference) {
    final path = reference.trim().replaceAll(RegExp(r'\s+'), '+');
    return _get(
      Uri.parse('$baseUrl/$path').replace(
        queryParameters: {'translation': translation},
      ),
      parseReferenceResponse,
    );
  }

  /// A random verse from [books] ("NT", "OT" or ids like "JHN,ROM"):
  /// `GET /data/kjv/random/NT`.
  Future<Result<Verse, BibleApiFailure>> fetchRandom({String books = 'NT'}) =>
      _get(
        Uri.parse('$baseUrl/data/$translation/random/$books'),
        parseRandomResponse,
      );

  Future<Result<Verse, BibleApiFailure>> _get(
    Uri uri,
    Verse Function(Object? body) parse,
  ) async {
    for (var attempt = 1; ; attempt++) {
      final result = await _attempt(uri, parse);
      if (result case Err(error: final failure)
          when failure.isTransient && attempt < _maxAttempts) {
        await Future<void>.delayed(retryDelay);
        continue;
      }
      return result;
    }
  }

  Future<Result<Verse, BibleApiFailure>> _attempt(
    Uri uri,
    Verse Function(Object? body) parse,
  ) async {
    final http.Response response;
    try {
      response = await _http.get(uri, headers: _headers).timeout(timeout);
    } on TimeoutException {
      return const Err(BibleApiTimeout());
    } on Exception catch (e) {
      return Err(BibleApiNetworkError(e));
    }

    switch (response.statusCode) {
      case 200:
        break;
      case 429:
        return Err(BibleApiRateLimited(retryAfter: _retryAfter(response)));
      case 403:
        return const Err(BibleApiBlocked());
      case 404:
        return const Err(BibleApiNotFound());
      case final status when status >= 500:
        return Err(BibleApiServerError(status));
      case final status:
        return Err(BibleApiRejected(status));
    }

    try {
      final body = jsonDecode(
        utf8.decode(response.bodyBytes, allowMalformed: true),
      );
      return Ok(parse(body));
    } on FormatException catch (e) {
      return Err(BibleApiMalformed(e.message));
    }
  }

  static Duration? _retryAfter(http.Response response) {
    final seconds = int.tryParse(response.headers['retry-after'] ?? '');
    return seconds == null ? null : Duration(seconds: seconds);
  }
}

/// `/{reference}` shape:
///   {reference, verses: [{book_id, book_name, chapter, verse, text}], text,
///    translation_id, translation_name, translation_note}
/// Throws [FormatException] when no reference and non-empty text remain.
Verse parseReferenceResponse(Object? body) {
  if (body is! Map) throw const FormatException('body is not an object');
  final reference = body['reference'];
  if (reference is! String || reference.trim().isEmpty) {
    throw const FormatException('missing reference');
  }
  var text = body['text'] is String ? Verse.normalize(body['text'] as String) : '';
  if (text.isEmpty && body['verses'] is List) {
    text = Verse.normalize([
      for (final v in body['verses'] as List)
        if (v is Map && v['text'] is String) v['text'] as String,
    ].join(' '));
  }
  if (text.isEmpty) throw const FormatException('missing text');
  return Verse(reference: reference.trim(), text: text);
}

/// `/data/{translation}/random/{books}` shape (no `reference` field):
///   {translation: {identifier, name, ...},
///    random_verse: {book_id, book, chapter, verse, text}}
Verse parseRandomResponse(Object? body) {
  if (body is! Map) throw const FormatException('body is not an object');
  final verse = body['random_verse'];
  if (verse is! Map) throw const FormatException('missing random_verse');
  final book = verse['book'] ?? verse['book_name'];
  final chapter = _positiveInt(verse['chapter']);
  final number = _positiveInt(verse['verse']);
  final text = verse['text'] is String
      ? Verse.normalize(verse['text'] as String)
      : '';
  if (book is! String || book.trim().isEmpty || chapter == null || number == null) {
    throw const FormatException('incomplete random_verse');
  }
  if (text.isEmpty) throw const FormatException('missing text');
  return Verse(reference: '${book.trim()} $chapter:$number', text: text);
}

/// Accepts 16 or "16".
int? _positiveInt(Object? value) {
  final n = value is int ? value : int.tryParse('$value');
  return n != null && n > 0 ? n : null;
}
