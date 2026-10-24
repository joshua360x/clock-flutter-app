import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/prayer_times/calculation_method.dart';
import 'package:prayer_alarm/prayer_times/geo_point.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';
import 'package:prayer_alarm/prayer_times/prayer_schedule.dart';
import 'package:prayer_alarm/prayer_times/timetable.dart';
import 'package:prayer_alarm/prayer_times/wall_time.dart';

import '../support/tz_zone_rules.dart';

/// New York, 25–26 Oct 2026 (EDT, UTC-4).
Timetable _twoDays() {
  PrayerDay day(int d, List<String> walls) => PrayerDay(
    date: DateTime.utc(2026, 10, d),
    times: {
      for (final (i, prayer) in Prayer.values.indexed)
        prayer: () {
          final wall = WallTime.tryParse(walls[i])!;
          return PrayerTime(
            at: DateTime.utc(2026, 10, d, wall.hour + 4, wall.minute),
            wall: wall,
          );
        }(),
    },
  );
  return Timetable(
    location: const GeoPoint(40.7128, -74.006),
    method: CalculationMethods.isna,
    school: AsrSchool.standard,
    timeZone: 'America/New_York',
    fetchedAt: DateTime.utc(2026, 10, 25),
    days: [
      day(26, ['05:42', '12:46', '15:48', '18:07', '19:23']),
      day(25, ['05:41', '12:46', '15:49', '18:08', '19:25']),
    ],
  );
}

void main() {
  final schedule = PrayerSchedule(
    _twoDays(),
    zoneRulesFor: (zone) => TzZoneRules(zone ?? 'America/New_York'),
  );
  // 25 Oct 2026, 14:00 EDT.
  final afternoon = DateTime.utc(2026, 10, 25, 18);

  test('next ring for each prayer uses the fetched AlAdhan time', () {
    expect(
      schedule.nextRing(Prayer.asr, afternoon),
      DateTime.utc(2026, 10, 25, 19, 49),
    );
    expect(
      schedule.nextRing(Prayer.fajr, afternoon),
      DateTime.utc(2026, 10, 26, 9, 42),
    );
  });

  test('nextDue is the soonest enabled prayer', () {
    final due = schedule.nextDue(Prayer.values, afternoon)!;

    expect(due.prayer, Prayer.asr);
    expect(due.at, DateTime.utc(2026, 10, 25, 19, 49));
  });

  test('disabled prayers are skipped', () {
    final due = schedule.nextDue([Prayer.fajr, Prayer.isha], afternoon)!;

    expect(due.prayer, Prayer.isha);
  });

  test('nextDue is null when every alarm is off', () {
    expect(schedule.nextDue(const [], afternoon), isNull);
  });

  test('after the table ends, the last fetched time repeats daily', () {
    // 27 Oct, 08:00 EDT: past every fetched Fajr.
    final later = DateTime.utc(2026, 10, 27, 12);

    expect(schedule.isFetched(Prayer.fajr, later), isFalse);
    expect(schedule.fallbackTime(Prayer.fajr), const WallTime(5, 42));
    expect(
      schedule.nextRing(Prayer.fajr, later),
      DateTime.utc(2026, 10, 28, 9, 42),
    );
  });

  test('before anything is fetched, the original five times are used', () {
    const empty = PrayerSchedule(null);

    expect(
      [for (final p in Prayer.values) empty.fallbackTime(p).toString()],
      ['06:00', '13:00', '16:30', '19:00', '20:00'],
    );
    expect(empty.isFetched(Prayer.fajr, afternoon), isFalse);
  });
}
