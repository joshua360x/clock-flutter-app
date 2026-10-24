import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/core/result.dart';
import 'package:prayer_alarm/scripture/bible_api_client.dart';
import 'package:prayer_alarm/scripture/scripture_service.dart';
import 'package:prayer_alarm/scripture/verse.dart';
import 'package:prayer_alarm/scripture/verse_cache.dart';
import 'package:prayer_alarm/scripture/verse_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Replays scripted results and records what it was asked to avoid.
class ScriptedSource implements VerseSource {
  final replies = <Result<Verse, BibleApiFailure>>[];
  final avoided = <Set<String>>[];
  int calls = 0;

  @override
  Future<Result<Verse, BibleApiFailure>> next({Set<String> avoid = const {}}) async {
    avoided.add(avoid);
    calls++;
    return replies.isEmpty ? const Err(BibleApiTimeout()) : replies.removeAt(0);
  }
}

Verse v(String ref, [String text = 'text']) => Verse(reference: ref, text: text);

void main() {
  const bundled = [
    Verse(reference: 'Philippians 4:13', text: 'I can do all things through Christ which strengtheneth me.'),
    Verse(reference: 'Hebrews 13:8', text: 'Jesus Christ the same yesterday, and to day, and for ever.'),
    Verse(reference: '1 John 4:19', text: 'We love him, because he first loved us.'),
  ];

  late ScriptedSource source;
  late SharedPreferences prefs;
  late DateTime now;

  setUp(() async {
    source = ScriptedSource();
    now = DateTime.utc(2026, 10, 25, 10);
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ScriptureService service({List<Verse> bundledVerses = bundled}) => ScriptureService(
    source: source,
    cache: VerseCache(prefs),
    bundled: bundledVerses,
    now: () => now,
    random: Random(1),
  );

  group('verseForAlarm (instant, offline, never blank)', () {
    test('uses a prefetched verse without touching the network', () async {
      await VerseCache(prefs).setQueue([v('Romans 8:28', 'Prefetched.')]);

      final verse = service().verseForAlarm('fajr@2026-10-25T09:41Z');

      expect(verse.text, 'Prefetched.');
      expect(source.calls, 0);
      expect(VerseCache(prefs).queue, isEmpty);
    });

    test('empty cache (offline at 6 AM): a bundled verse', () {
      final verse = service().verseForAlarm('fajr@2026-10-25T09:41Z');

      expect(bundled, contains(verse));
      expect(source.calls, 0);
    });

    test('no bundled verses either: John 3:16, never blank', () {
      final verse = service(bundledVerses: const []).verseForAlarm('fajr');

      expect(verse, fallbackVerse);
      expect(verse.text, isNotEmpty);
    });

    test('the same ringing alarm keeps its verse, even after a restart', () {
      final first = service().verseForAlarm('fajr@2026-10-25T09:41Z');

      expect(service().verseForAlarm('fajr@2026-10-25T09:41Z'), first);
    });

    test('consecutive alarms do not repeat bundled verses', () {
      final s = service();
      final shown = {
        for (final key in ['fajr', 'dhuhr', 'asr']) s.verseForAlarm(key).reference,
      };

      expect(shown, hasLength(3));
    });
  });

  group('prefetch', () {
    test('fills the queue to three, avoiding what is already queued', () async {
      source.replies.addAll([Ok(v('A')), Ok(v('B')), Ok(v('C'))]);

      final outcome = await service().prefetch();

      expect((outcome as PrefetchFilled).added, 3);
      expect(VerseCache(prefs).queue.map((x) => x.reference), ['A', 'B', 'C']);
      expect(source.avoided[2], containsAll(['A', 'B']));
    });

    test('queue already full: no requests', () async {
      await VerseCache(prefs).setQueue([v('A'), v('B'), v('C')]);

      expect(await service().prefetch(), isA<PrefetchFilled>());
      expect(source.calls, 0);
    });

    test('never more than three requests per call', () async {
      // Every reply is a duplicate, so the queue never fills.
      source.replies.addAll(List.filled(10, Ok(v('A'))));
      await VerseCache(prefs).setQueue([v('A')]);

      await service().prefetch();

      expect(source.calls, 3);
    });

    test('too-long verses are dropped so the screen never overflows', () async {
      source.replies.addAll([Ok(v('Long', 'x' * 400)), Ok(v('Short'))]);

      await service().prefetch();

      expect(VerseCache(prefs).queue.map((x) => x.reference), ['Short']);
    });

    test('called again within 30 s: skipped without a request', () async {
      final s = service();
      source.replies.add(Ok(v('A')));
      await s.prefetch();
      final calls = source.calls;

      now = now.add(const Duration(seconds: 10));

      expect(await s.prefetch(), isA<PrefetchSkipped>());
      expect(source.calls, calls);
    });

    test('rate limited: stops, cools down 60 s, then tries again', () async {
      source.replies.addAll([Ok(v('A')), const Err(BibleApiRateLimited())]);

      final outcome = await service().prefetch();
      expect(outcome, isA<PrefetchStopped>());
      expect((outcome as PrefetchStopped).added, 1);

      now = now.add(const Duration(seconds: 59));
      expect(await service().prefetch(), isA<PrefetchSkipped>());
      expect(source.calls, 2);

      now = now.add(const Duration(seconds: 2));
      source.replies.addAll([Ok(v('B')), Ok(v('C'))]);
      expect(await service().prefetch(), isA<PrefetchFilled>());
    });

    test('Retry-After overrides the default cool-down', () async {
      source.replies.add(const Err(BibleApiRateLimited(retryAfter: Duration(seconds: 5))));
      await service().prefetch();

      now = now.add(const Duration(seconds: 6));
      source.replies.addAll([Ok(v('A'))]);

      expect(await service().prefetch(), isNot(isA<PrefetchSkipped>()));
    });

    test('blocked (403): one-hour cool-down that survives a restart', () async {
      source.replies.add(const Err(BibleApiBlocked()));
      await service().prefetch();

      now = now.add(const Duration(minutes: 59));
      expect(await service().prefetch(), isA<PrefetchSkipped>());

      now = now.add(const Duration(minutes: 2));
      source.replies.add(Ok(v('A')));
      expect(await service().prefetch(), isNot(isA<PrefetchSkipped>()));
    });

    test('404 stops immediately (no streak of not-founds)', () async {
      source.replies.addAll([const Err(BibleApiNotFound()), Ok(v('A'))]);

      final outcome = await service().prefetch();

      expect((outcome as PrefetchStopped).failure, isA<BibleApiNotFound>());
      expect(source.calls, 1);
    });

    test('timeout or malformed response: stop, keep what was queued', () async {
      await VerseCache(prefs).setQueue([v('Kept')]);
      source.replies.add(const Err(BibleApiMalformed('html')));

      await service().prefetch();

      expect(VerseCache(prefs).queue.map((x) => x.reference), ['Kept']);
      expect(service().verseForAlarm('isha').reference, 'Kept');
    });

    test('recently shown references are avoided', () async {
      final s = service();
      final shown = s.verseForAlarm('fajr').reference;
      source.replies.add(Ok(v('A')));

      await s.prefetch();

      expect(source.avoided.first, contains(shown));
    });
  });
}
