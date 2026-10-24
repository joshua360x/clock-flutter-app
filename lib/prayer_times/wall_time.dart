/// A time of day on a wall clock (no date, no zone), e.g. 05:41.
class WallTime {
  const WallTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  final int hour;
  final int minute;

  /// Parses the leading `HH:mm` of [text], ignoring anything after it, so
  /// AlAdhan's `"05:41 (EDT)"` and plain `"05:41"` both work.
  static WallTime? tryParse(String text) {
    final match = RegExp(r'^\s*(\d{1,2}):(\d{2})').firstMatch(text);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return WallTime(hour, minute);
  }

  int get minutesSinceMidnight => hour * 60 + minute;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is WallTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}
