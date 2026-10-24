import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';
import 'package:prayer_alarm/ui/alarm_list/alarm_list_screen.dart';
import 'package:prayer_alarm/ui/theme/app_colors.dart';

import '../support/themed.dart';

void main() {
  final toggles = <(Prayer, bool)>[];

  Widget screen({Brightness brightness = Brightness.dark, bool use24h = true}) => themed(
    AlarmListScreen(
      rows: const [
        AlarmRowData(prayer: Prayer.fajr, time: TimeOfDay(hour: 5, minute: 42), enabled: true, isNextDue: false),
        AlarmRowData(prayer: Prayer.dhuhr, time: TimeOfDay(hour: 12, minute: 46), enabled: false, isNextDue: false),
        AlarmRowData(prayer: Prayer.asr, time: TimeOfDay(hour: 15, minute: 49), enabled: true, isNextDue: true),
        AlarmRowData(prayer: Prayer.maghrib, time: TimeOfDay(hour: 18, minute: 8), enabled: true, isNextDue: false),
        AlarmRowData(prayer: Prayer.isha, time: TimeOfDay(hour: 19, minute: 25), enabled: true, isNextDue: false),
      ],
      sourceLine: 'AlAdhan · Islamic Society of North America',
      themeLabel: 'Dark',
      onToggle: (p, on) => toggles.add((p, on)),
      onCycleTheme: () {},
      onPreviewAlarm: () {},
    ),
    brightness: brightness,
    use24h: use24h,
  );

  setUp(toggles.clear);

  Future<void> pump24h(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
  }

  testWidgets('one row per prayer with time, name and toggle; dividers between', (tester) async {
    await pump24h(tester, screen());

    for (final t in ['05:42', '12:46', '15:49', '18:08', '19:25']) {
      expect(find.text(t), findsOneWidget);
    }
    for (final p in Prayer.values) {
      expect(find.text(p.label), findsOneWidget);
    }
    expect(find.byType(Switch), findsNWidgets(5));
    expect(find.byType(Divider), findsNWidgets(4));
  });

  for (final brightness in Brightness.values) {
    testWidgets('$brightness: accent only on the next alarm due', (tester) async {
      await pump24h(tester, screen(brightness: brightness));
      final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;

      final accented = textRuns(tester).where((r) => r.style.color == colors.accentText);

      expect(accented.map((r) => r.text), ['15:49']);
    });
  }

  testWidgets('a switched-off alarm drops to the muted colour', (tester) async {
    await pump24h(tester, screen());

    final runs = textRuns(tester);
    Color? colorOf(String text) => runs.firstWhere((r) => r.text == text).style.color;

    expect(colorOf('12:46'), AppColors.dark.muted);
    expect(colorOf('Dhuhr'), AppColors.dark.muted);
    expect(colorOf('05:42'), AppColors.dark.text);
  });

  testWidgets('switch and row tap both toggle', (tester) async {
    await pump24h(tester, screen());

    await tester.tap(find.byType(Switch).first);
    await tester.tap(find.text('Dhuhr'));

    expect(toggles, [(Prayer.fajr, false), (Prayer.dhuhr, true)]);
  });

  testWidgets('touch targets are at least 48dp', (tester) async {
    await pump24h(tester, screen());

    for (final element in find.byType(Switch).evaluate()) {
      final size = tester.getSize(find.byWidget(element.widget));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    }
    for (final element in find.byType(TextButton).evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height, greaterThanOrEqualTo(48));
    }
    final rowHeight = tester.getSize(find.byType(InkWell).first).height;
    expect(rowHeight, greaterThanOrEqualTo(48));
  });

  testWidgets('12-hour phones show a small AM/PM beside the time', (tester) async {
    await tester.pumpWidget(screen(use24h: false));

    final runs = textRuns(tester);
    expect(runs.any((r) => r.text == '3:49'), isTrue);
    expect(runs.any((r) => r.text == ' PM'), isTrue);
  });
}
