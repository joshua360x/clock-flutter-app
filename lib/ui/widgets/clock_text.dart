import 'package:flutter/material.dart';

/// "05:42" on 24-hour phones, ("5:42", "AM") on 12-hour phones.
({String clock, String? period}) formatClock(
  TimeOfDay time, {
  required bool use24h,
}) {
  String two(int n) => n.toString().padLeft(2, '0');
  if (use24h) return (clock: '${two(time.hour)}:${two(time.minute)}', period: null);
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  return (
    clock: '$hour:${two(time.minute)}',
    period: time.period == DayPeriod.am ? 'AM' : 'PM',
  );
}

/// A time in [style], with a smaller AM/PM in [periodStyle] when the phone
/// uses 12-hour time.
class ClockText extends StatelessWidget {
  const ClockText(
    this.time, {
    super.key,
    required this.style,
    required this.periodStyle,
  });

  final TimeOfDay time;
  final TextStyle style;
  final TextStyle periodStyle;

  @override
  Widget build(BuildContext context) {
    final (:clock, :period) = formatClock(
      time,
      use24h: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: clock, style: style),
          if (period != null) TextSpan(text: ' $period', style: periodStyle),
        ],
      ),
      semanticsLabel: period == null ? clock : '$clock $period',
    );
  }
}
