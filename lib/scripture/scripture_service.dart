import 'dart:async';
import 'dart:math';

import '../core/result.dart';
import 'bible_api_client.dart';
import 'verse.dart';
import 'verse_cache.dart';
import 'verse_source.dart';

sealed class PrefetchOutcome {
  const PrefetchOutcome();
}

/// Queue topped up (possibly by zero if it was already full).
final class PrefetchFilled extends PrefetchOutcome {
  const PrefetchFilled(this.added);
  final int added;
}

/// Skipped without any request: cooling down after 429/403, or called again
/// too soon.
final class PrefetchSkipped extends PrefetchOutcome {
  const PrefetchSkipped(this.until);
  final DateTime until;
}

/// Stopped at a failure; whatever was queued before stays queued.
final class PrefetchStopped extends PrefetchOutcome {
  const PrefetchStopped(this.failure, {required this.added});
  final BibleApiFailure failure;
  final int added;
}

/// Picks the verse for each alarm and keeps a few fetched ahead of time.
///
/// [verseForAlarm] never touches the network and never returns an empty
/// verse: prefetched queue → bundled KJV verses → [fallbackVerse]. Offline
/// at 6 AM is the normal case. [prefetch] tops the queue up when the app
/// runs, within bible-api's limits.
class ScriptureService {
  ScriptureService({
    required VerseSource source,
    required VerseCache cache,
    required List<Verse> bundled,
    DateTime Function()? now,
    Random? random,
    this.queueTarget = 3,
    this.maxRequestsPerPrefetch = 3,
    this.minPrefetchInterval = const Duration(seconds: 30),
    this.rateLimitCooldown = const Duration(seconds: 60),
    this.blockedCooldown = const Duration(hours: 1),
    this.maxChars = 320,
  }) : _source = source,
       _cache = cache,
       _bundled = bundled,
       _now = now ?? DateTime.now,
       _random = random ?? Random();

  final VerseSource _source;
  final VerseCache _cache;
  final List<Verse> _bundled;
  final DateTime Function() _now;
  final Random _random;

  final int queueTarget;
  final int maxRequestsPerPrefetch;

  /// Spacing between prefetches; with [maxRequestsPerPrefetch] this keeps
  /// the app far below bible-api's 15 requests per 30 seconds.
  final Duration minPrefetchInterval;
  final Duration rateLimitCooldown;
  final Duration blockedCooldown;

  /// Longer verses are dropped so the text fits the alarm screen.
  final int maxChars;

  DateTime? _lastPrefetch;

  /// The verse for one ringing alarm, identified by [alarmKey] (e.g. prayer
  /// and scheduled time). Reopening the same alarm shows the same verse.
  Verse verseForAlarm(String alarmKey) {
    final assigned = _cache.assigned;
    if (assigned != null && assigned.key == alarmKey) return assigned.verse;

    final queue = _cache.queue;
    final Verse verse;
    if (queue.isNotEmpty) {
      verse = queue.first;
      unawaited(_cache.setQueue(queue.sublist(1)));
    } else {
      verse = _pickBundled();
    }
    unawaited(_cache.assign(alarmKey, verse));
    unawaited(_cache.markShown(verse.reference));
    return verse;
  }

  Verse _pickBundled() {
    if (_bundled.isEmpty) return fallbackVerse;
    final recent = _cache.recentReferences.toSet();
    final fresh = _bundled.where((v) => !recent.contains(v.reference)).toList();
    final pool = fresh.isEmpty ? _bundled : fresh;
    return pool[_random.nextInt(pool.length)];
  }

  Future<PrefetchOutcome> prefetch() async {
    final now = _now();
    final cooldown = _cache.cooldownUntil;
    if (cooldown != null && now.isBefore(cooldown)) {
      return PrefetchSkipped(cooldown);
    }
    final last = _lastPrefetch;
    if (last != null && now.difference(last) < minPrefetchInterval) {
      return PrefetchSkipped(last.add(minPrefetchInterval));
    }
    _lastPrefetch = now;

    final queue = [..._cache.queue];
    var added = 0;
    for (
      var requests = 0;
      queue.length < queueTarget && requests < maxRequestsPerPrefetch;
      requests++
    ) {
      final avoid = {
        ..._cache.recentReferences,
        for (final v in queue) v.reference,
        if (_cache.assigned case final a?) a.verse.reference,
      };
      switch (await _source.next(avoid: avoid)) {
        case Ok(value: final verse):
          if (verse.text.length <= maxChars && !avoid.contains(verse.reference)) {
            queue.add(verse);
            added++;
            await _cache.setQueue(queue);
          }
        case Err(error: final failure):
          await _coolDownAfter(failure, now);
          return PrefetchStopped(failure, added: added);
      }
    }
    return PrefetchFilled(added);
  }

  Future<void> _coolDownAfter(BibleApiFailure failure, DateTime now) async {
    final wait = switch (failure) {
      BibleApiRateLimited(:final retryAfter) => retryAfter ?? rateLimitCooldown,
      BibleApiBlocked() => blockedCooldown,
      _ => null,
    };
    if (wait != null) await _cache.setCooldownUntil(now.add(wait));
  }
}
