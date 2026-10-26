import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/audio/alarm_sound.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';

void main() {
  test('one file for every alarm: custom/default.mp3', () {
    final resolver = BundledSoundResolver(['assets/audio/custom/default.mp3']);

    for (final prayer in Prayer.values) {
      expect(resolver.soundFor(prayer), const AssetSound('assets/audio/custom/default.mp3'));
    }
  });

  test('a per-prayer file wins for that prayer only, any supported extension', () {
    final resolver = BundledSoundResolver([
      'assets/audio/custom/default.mp3',
      'assets/audio/custom/fajr.m4a',
      'assets/audio/custom/isha.ogg',
    ]);

    expect(resolver.soundFor(Prayer.fajr), const AssetSound('assets/audio/custom/fajr.m4a'));
    expect(resolver.soundFor(Prayer.isha), const AssetSound('assets/audio/custom/isha.ogg'));
    expect(resolver.soundFor(Prayer.asr), const AssetSound('assets/audio/custom/default.mp3'));
  });

  test('no custom files: the built-in bell', () {
    final resolver = BundledSoundResolver(['assets/audio/custom/README.md']);

    expect(resolver.soundFor(Prayer.maghrib), bellSound);
  });

  test('wire format the native engine reads', () {
    expect(bellSound.toWire(), {'kind': 'asset', 'path': 'assets/audio/bell.ogg'});
    expect(const FileSound('/data/x/fajr.m4a').toWire(), {'kind': 'file', 'path': '/data/x/fajr.m4a'});
  });

  testWidgets('the real asset bundle ships the bell', (tester) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    expect(manifest.listAssets(), contains('assets/audio/bell.ogg'));
  });
}
