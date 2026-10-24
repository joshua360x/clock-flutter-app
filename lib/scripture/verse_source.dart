import 'dart:math';

import '../core/result.dart';
import 'bible_api_client.dart';
import 'verse.dart';

/// Where live verses come from. Swap the implementation to change what the
/// alarm shows; caching, fallbacks and rate limits stay in ScriptureService.
abstract interface class VerseSource {
  /// One verse, preferring references not in [avoid].
  Future<Result<Verse, BibleApiFailure>> next({Set<String> avoid});
}

/// Curated encouraging passages, fetched live by reference (current choice).
class CuratedVerseSource implements VerseSource {
  CuratedVerseSource(this._client, this.references, {Random? random})
    : assert(references.isNotEmpty),
      _random = random ?? Random();

  final BibleApiClient _client;
  final List<String> references;
  final Random _random;

  @override
  Future<Result<Verse, BibleApiFailure>> next({Set<String> avoid = const {}}) {
    final fresh = references.where((r) => !avoid.contains(r)).toList();
    final pool = fresh.isEmpty ? references : fresh;
    return _client.fetchReference(pool[_random.nextInt(pool.length)]);
  }
}

/// Any random verse from the given books. Not curated: verses can be
/// fragments or out of context. Kept for when the source changes.
class RandomVerseSource implements VerseSource {
  RandomVerseSource(this._client, {this.books = 'NT'});

  final BibleApiClient _client;
  final String books;

  @override
  Future<Result<Verse, BibleApiFailure>> next({Set<String> avoid = const {}}) =>
      _client.fetchRandom(books: books);
}
