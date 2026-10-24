import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/app.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';
import 'package:prayer_alarm/ui/ringing/ringing_screen.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('app starts offline on the alarm list, dark by default', (tester) async {
    final controller = await offlineController(now: () => DateTime(2026, 10, 25, 14));

    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('PRAYER TIMES'), findsOneWidget);
    for (final prayer in Prayer.values) {
      expect(find.text(prayer.label), findsOneWidget);
    }
    expect(find.text('Approximate times until your location is available'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('preview opens the ringing screen with a verse, Dismiss closes it', (tester) async {
    final controller = await offlineController(now: () => DateTime(2026, 10, 25, 14));
    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Preview alarm'), 200);
    await tester.tap(find.text('Preview alarm'));
    await tester.pumpAndSettle();

    expect(find.byType(RingingScreen), findsOneWidget);
    expect(find.textContaining('For God so loved the world'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.byType(RingingScreen), findsNothing);
  });

  testWidgets('theme cycles Dark → Light → System and is remembered', (tester) async {
    final controller = await offlineController(now: () => DateTime(2026, 10, 25, 14));
    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Theme · Dark'), 200);
    await tester.tap(find.text('Theme · Dark'));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.light);

    await tester.tap(find.text('Theme · Light'));
    await tester.pumpAndSettle();
    expect(find.text('Theme · System'), findsOneWidget);
    expect(controller.theme.mode, ThemeMode.system);
  });
}
