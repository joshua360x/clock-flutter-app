import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/alarms/alarm_engine.dart';
import 'package:prayer_alarm/app.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';
import 'package:prayer_alarm/ui/ringing/ringing_screen.dart';

import 'support/app_harness.dart';
import 'support/fake_alarm_engine.dart';

DateTime _now() => DateTime(2026, 10, 25, 14);

RingingAlarm _fajr({bool test = false}) => RingingAlarm(
  alarmId: 1,
  key: 'fajr',
  label: 'Fajr',
  scheduledAt: DateTime(2026, 10, 26, 6),
  isTest: test,
);

void main() {
  testWidgets('app starts offline on the alarm list, dark by default', (tester) async {
    final controller = await offlineController(now: _now);

    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('PRAYER TIMES'), findsOneWidget);
    for (final prayer in Prayer.values) {
      expect(find.text(prayer.label), findsOneWidget);
    }
    expect(find.text('Approximate times until your location is available'), findsOneWidget);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
  });

  testWidgets('first launch asks for notifications and location, once', (tester) async {
    final engine = FakeAlarmEngine()
      ..missing = {ReliabilityItem.notifications, ReliabilityItem.location, ReliabilityItem.batteryOptimization};
    final controller = await offlineController(now: _now, engine: engine);

    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    expect(engine.fixed, [ReliabilityItem.notifications, ReliabilityItem.location]);
    // Battery optimisation is not auto-prompted; it is listed instead.
    expect(find.text(ReliabilityItem.batteryOptimization.title), findsOneWidget);

    await tester.tap(find.text(ReliabilityItem.batteryOptimization.title));
    await tester.pumpAndSettle();
    expect(engine.fixed.last, ReliabilityItem.batteryOptimization);
    expect(find.text(ReliabilityItem.batteryOptimization.title), findsNothing);
  });

  testWidgets('the schedule is synced on start and on every toggle', (tester) async {
    final engine = FakeAlarmEngine();
    final controller = await offlineController(now: _now, engine: engine);
    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();
    final before = engine.synced.length;

    await tester.tap(find.text('Dhuhr'));
    await tester.pumpAndSettle();

    expect(engine.synced.length, before + 1);
    final alarms = engine.synced.last['alarms']! as List;
    final dhuhr = alarms.cast<Map<String, Object?>>().firstWhere((a) => a['key'] == 'dhuhr');
    expect(dhuhr['enabled'], isFalse);
  });

  testWidgets('Test alarm asks the engine to ring the next prayer in 10 s', (tester) async {
    final engine = FakeAlarmEngine();
    final controller = await offlineController(now: _now, engine: engine);
    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Test alarm'), 200);
    await tester.tap(find.text('Test alarm'));
    await tester.pumpAndSettle();

    // 14:00 → next is Asr (16:30 fallback).
    expect(engine.tests.single, (alarmId: Prayer.asr.id, delay: const Duration(seconds: 10)));
    expect(find.textContaining('Test alarm rings in 10 seconds'), findsOneWidget);
  });

  testWidgets('a ringing alarm covers the app; Dismiss stops it', (tester) async {
    final engine = FakeAlarmEngine();
    final controller = await offlineController(now: _now, engine: engine);
    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    engine.ring(_fajr());
    await tester.pumpAndSettle();

    expect(find.byType(RingingScreen), findsOneWidget);
    expect(find.text('FAJR'), findsOneWidget);
    expect(find.textContaining('For God so loved the world'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(engine.dismissals, 1);
    expect(find.byType(RingingScreen), findsNothing);
    expect(find.text('PRAYER TIMES'), findsOneWidget);
  });

  testWidgets('cold start while ringing opens straight onto the alarm; Snooze', (tester) async {
    final engine = FakeAlarmEngine()..ringingNow = _fajr();
    final controller = await offlineController(now: _now, engine: engine);

    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byType(RingingScreen), findsOneWidget);

    await tester.tap(find.text('Snooze'));
    await tester.pumpAndSettle();

    expect(engine.snoozes, 1);
    expect(find.byType(RingingScreen), findsNothing);
  });

  testWidgets('stopped from the notification: the alarm screen goes away', (tester) async {
    final engine = FakeAlarmEngine()..ringingNow = _fajr();
    final controller = await offlineController(now: _now, engine: engine);
    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    engine.ring(null);
    await tester.pumpAndSettle();

    expect(find.byType(RingingScreen), findsNothing);
  });

  testWidgets('theme cycles Dark → Light → System and is remembered', (tester) async {
    final controller = await offlineController(now: _now);
    await tester.pumpWidget(PrayerAlarmApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Theme · Dark'), 200);
    await tester.tap(find.text('Theme · Dark'));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.light);

    await tester.tap(find.text('Theme · Light'));
    await tester.pumpAndSettle();
    expect(controller.theme.mode, ThemeMode.system);
  });
}
