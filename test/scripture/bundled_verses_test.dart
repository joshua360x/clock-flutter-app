import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/scripture/bundled_verses.dart';
import 'package:prayer_alarm/scripture/verse.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the shipped KJV list loads, includes John 3:16, and fits the screen', () async {
    final verses = await loadBundledVerses(rootBundle);

    expect(verses.length, greaterThanOrEqualTo(50));
    expect(verses, contains(fallbackVerse));
    expect(verses.map((v) => v.reference).toSet(), hasLength(verses.length));
    for (final verse in verses) {
      expect(verse.text.length, lessThanOrEqualTo(320), reason: verse.reference);
      expect(verse.text, isNot(contains('  ')), reason: verse.reference);
      expect(verse.text, isNot(matches(RegExp(r'[a-z][A-Z]'))), reason: verse.reference);
    }
  });

  test('the asset declares KJV', () {
    final raw = File(bundledVersesAsset).readAsStringSync();

    expect(raw, contains('"id": "kjv"'));
  });

  test('a broken or missing asset gives an empty list, not a crash', () {
    expect(parseBundledVerses('not json'), isEmpty);
    expect(parseBundledVerses('{"verses": "x"}'), isEmpty);
    expect(
      parseBundledVerses('{"verses": [{"reference": "John 3:16", "text": "  "}, {"reference": "Luke 1:37", "text": "For with God nothing shall be impossible."}]}')
          .map((v) => v.reference),
      ['Luke 1:37'],
    );
  });
}
