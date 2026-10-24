import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/scripture/verse.dart';
import 'package:prayer_alarm/ui/ringing/ringing_screen.dart';
import 'package:prayer_alarm/ui/theme/app_colors.dart';
import 'package:prayer_alarm/ui/theme/app_text.dart';

import '../support/themed.dart';

const _romans = Verse(
  reference: 'Romans 8:38-39',
  text:
      'For I am persuaded, that neither death, nor life, nor angels, nor '
      'principalities, nor powers, nor things present, nor things to come, '
      'Nor height, nor depth, nor any other creature, shall be able to '
      'separate us from the love of God, which is in Christ Jesus our Lord.',
);

void main() {
  var dismissed = 0, snoozed = 0;

  Widget screen({Verse verse = fallbackVerse, Brightness brightness = Brightness.dark}) =>
      themed(
        RingingScreen(
          label: 'Fajr',
          time: const TimeOfDay(hour: 5, minute: 42),
          verse: verse,
          onDismiss: () => dismissed++,
          onSnooze: () => snoozed++,
        ),
        brightness: brightness,
      );

  setUp(() => dismissed = snoozed = 0);

  Future<void> pump(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
  }

  testWidgets('label, time, verse and reference are shown', (tester) async {
    await pump(tester, screen());

    expect(find.text('FAJR'), findsOneWidget);
    expect(find.text('05:42'), findsOneWidget);
    expect(find.text(fallbackVerse.text), findsOneWidget);
    expect(find.text('John 3:16 · KJV'), findsOneWidget);
  });

  testWidgets('accent on the label and Dismiss only', (tester) async {
    await pump(tester, screen());
    final c = AppColors.dark;

    final accentText = textRuns(tester).where((r) => r.style.color == c.accentText);
    expect(accentText.map((r) => r.text), ['FAJR']);

    final dismiss = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(dismiss.style!.backgroundColor!.resolve({}), c.accentFill);
    expect(dismiss.style!.foregroundColor!.resolve({}), c.onAccent);
  });

  testWidgets('Lora is used for the verse and nothing else', (tester) async {
    await pump(tester, screen());

    final serif = textRuns(tester).where((r) => r.style.fontFamily == AppText.lora);
    expect(serif.map((r) => r.text), [fallbackVerse.text]);
  });

  testWidgets('Dismiss: full-width 64dp pill; Snooze: 52dp bare text below it', (tester) async {
    await pump(tester, screen());
    final screenWidth = tester.getSize(find.byType(Scaffold)).width;

    final dismiss = tester.getRect(find.byType(FilledButton));
    expect(dismiss.height, 64);
    expect(dismiss.width, screenWidth - 56);
    final shape = tester.widget<FilledButton>(find.byType(FilledButton)).style!.shape!
        .resolve({})! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(32));

    final snooze = tester.getRect(find.byType(TextButton));
    expect(snooze.height, 52);
    expect(snooze.top, greaterThan(dismiss.bottom));
    final snoozeStyle = tester.widget<TextButton>(find.byType(TextButton)).style!;
    expect(snoozeStyle.foregroundColor!.resolve({}), AppColors.dark.muted);
    expect(snoozeStyle.backgroundColor?.resolve({}), anyOf(isNull, Colors.transparent));
  });

  testWidgets('buttons call back', (tester) async {
    await pump(tester, screen());

    await tester.tap(find.text('Dismiss'));
    await tester.tap(find.text('Snooze'));

    expect((dismissed, snoozed), (1, 1));
  });

  testWidgets('longest verse fits a small phone at 130% text size without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pump(
      tester,
      MediaQuery(
        data: const MediaQueryData(size: Size(320, 568), textScaler: TextScaler.linear(1.3)),
        child: screen(verse: _romans),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(_romans.text), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('light theme renders with the light palette', (tester) async {
    await pump(tester, screen(brightness: Brightness.light));

    final label = textRuns(tester).firstWhere((r) => r.text == 'FAJR');
    expect(label.style.color, AppColors.light.accentText);
  });
}
