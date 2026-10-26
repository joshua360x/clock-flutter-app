// Renders the screens with the real fonts to build/screenshots/*.png for
// design review. Not part of `flutter test`; run explicitly:
//   flutter test screenshots/render_screens_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';
import 'package:prayer_alarm/scripture/verse.dart';
import 'package:prayer_alarm/ui/alarm_list/alarm_list_screen.dart';
import 'package:prayer_alarm/ui/ringing/ringing_screen.dart';
import 'package:prayer_alarm/ui/theme/app_theme.dart';

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
}

const _rows = [
  AlarmRowData(prayer: Prayer.fajr, time: TimeOfDay(hour: 5, minute: 42), enabled: true, isNextDue: false),
  AlarmRowData(prayer: Prayer.dhuhr, time: TimeOfDay(hour: 12, minute: 46), enabled: true, isNextDue: false),
  AlarmRowData(prayer: Prayer.asr, time: TimeOfDay(hour: 15, minute: 49), enabled: true, isNextDue: true),
  AlarmRowData(prayer: Prayer.maghrib, time: TimeOfDay(hour: 18, minute: 8), enabled: false, isNextDue: false),
  AlarmRowData(prayer: Prayer.isha, time: TimeOfDay(hour: 19, minute: 25), enabled: true, isNextDue: false),
];

const _verse = Verse(
  reference: 'Philippians 4:6-7',
  text:
      'Be careful for nothing; but in every thing by prayer and supplication '
      'with thanksgiving let your requests be made known unto God. And the '
      'peace of God, which passeth all understanding, shall keep your hearts '
      'and minds through Christ Jesus.',
);

void main() {
  setUpAll(() async {
    await _loadFont('Inter', 'assets/fonts/Inter-Variable.ttf');
    await _loadFont('Lora', 'assets/fonts/Lora-Variable.ttf');
  });

  Future<void> capture(WidgetTester tester, String name, Widget screen, Brightness brightness) async {
    tester.view.physicalSize = const Size(412 * 2, 915 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(brightness),
          builder: (context, app) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: app!,
          ),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/screenshots/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  for (final brightness in Brightness.values) {
    final theme = brightness.name;

    testWidgets('alarm list $theme', (tester) async {
      await capture(
        tester,
        'alarm_list_$theme',
        AlarmListScreen(
          rows: _rows,
          sourceLine: 'AlAdhan · Islamic Society of North America',
          themeLabel: brightness == Brightness.dark ? 'Dark' : 'Light',
          onToggle: (_, _) {},
          onCycleTheme: () {},
          onTestAlarm: () {},
        ),
        brightness,
      );
    });

    testWidgets('ringing $theme', (tester) async {
      await capture(
        tester,
        'ringing_$theme',
        RingingScreen(
          label: 'Fajr',
          time: const TimeOfDay(hour: 5, minute: 42),
          verse: _verse,
          onDismiss: () {},
          onSnooze: () {},
        ),
        brightness,
      );
    });
  }
}
