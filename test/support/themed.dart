import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/ui/theme/app_theme.dart';

/// [child] under the app theme, with the phone's 12/24-hour setting fixed so
/// time text is deterministic.
Widget themed(
  Widget child, {
  Brightness brightness = Brightness.dark,
  bool use24h = true,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildAppTheme(brightness),
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24h),
    child: app!,
  ),
  home: child,
);

/// Every styled run of text on screen, flattened out of RichText spans.
List<({String text, TextStyle style})> textRuns(WidgetTester tester) {
  final runs = <({String text, TextStyle style})>[];
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject! as RenderParagraph;
    void visit(InlineSpan span, TextStyle inherited) {
      final style = inherited.merge(span.style);
      if (span is TextSpan) {
        if (span.text != null && span.text!.trim().isNotEmpty) {
          runs.add((text: span.text!, style: style));
        }
        for (final child in span.children ?? const <InlineSpan>[]) {
          visit(child, style);
        }
      }
    }

    visit(paragraph.text, const TextStyle());
  }
  return runs;
}
