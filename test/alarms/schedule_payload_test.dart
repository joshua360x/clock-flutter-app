import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/alarms/alarm_settings.dart';
import 'package:prayer_alarm/alarms/schedule_payload.dart';
import 'package:prayer_alarm/audio/alarm_sound.dart';
import 'package:prayer_alarm/prayer_times/calculation_method.dart';
import 'package:prayer_alarm/prayer_times/geo_point.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';
import 'package:prayer_alarm/prayer_times/prayer_schedule.dart';
import 'package:prayer_alarm/prayer_times/timetable.dart';
import 'package:prayer_alarm/prayer_times/wall_time.dart';

/// New York, 26–27 Oct 2026, EDT (UTC-4).
Timetable _timetable() {
  const walls = {
    26: ['05:42', '12:46', '15:48', '18:07', '19:23'],
    27: ['05:43', '12:46', '15:47', '18:06', '19:22'],
  };
  return Timetable(
    location: const GeoPoint(40.7128, -74.006),
    method: CalculationMethods.isna,
    school: AsrSchool.standard,
    timeZone: 'America/New_York',
    fetchedAt: DateTime.utc(2026, 10, 25),
    days: [
      for (final MapEntry(key: day, value: times) in walls.entries)
        PrayerDay(
          date: DateTime.utc(2026, 10, day),
          times: {
            for (final (i, prayer) in Prayer.values.indexed)
              prayer: () {
                final wall = WallTime.tryParse(times[i])!;
                return PrayerTime(
                  at: DateTime.utc(2026, 10, day, wall.hour + 4, wall.minute),
                  wall: wall,
                );
              }(),
          },
        ),
    ],
  );
}

void main() {
  final sounds = BundledSoundResolver(['assets/audio/custom/default.mp3']);

  test('payload matches the sample the Kotlin parser is tested against', () {
    final payload = buildSchedulePayload(
      schedule: PrayerSchedule(_timetable()),
      settings: AlarmSettings.allOn().withEnabled(Prayer.dhuhr, false),
      sounds: sounds,
      now: DateTime.utc(2026, 10, 26),
    );

    final sample = jsonDecode(
      File('test/fixtures/schedule_payload_sample.json').readAsStringSync(),
    );
    expect(jsonDecode(jsonEncode(payload)), sample);
  });

  test('only times after now are sent', () {
    final payload = buildSchedulePayload(
      schedule: PrayerSchedule(_timetable()),
      settings: AlarmSettings.allOn(),
      sounds: sounds,
      now: DateTime.utc(2026, 10, 26, 12),
    );

    final fajr = (payload['alarms']! as List).first as Map;
    expect(fajr['instants'], [DateTime.utc(2026, 10, 27, 9, 43).millisecondsSinceEpoch]);
  });

  test('before any fetch: no instants, the original times, device zone', () {
    final payload = buildSchedulePayload(
      schedule: const PrayerSchedule(null),
      settings: AlarmSettings.allOn(),
      sounds: BundledSoundResolver(const []),
      now: DateTime.utc(2026, 10, 26),
    );

    final alarms = (payload['alarms']! as List).cast<Map<String, Object?>>();
    expect(alarms.map((a) => a['fallback']), ['06:00', '13:00', '16:30', '19:00', '20:00']);
    expect(alarms.every((a) => (a['instants']! as List).isEmpty), isTrue);
    expect(alarms.every((a) => a['zone'] == null), isTrue);
    expect(alarms.first['sound'], bellSound.toWire());
  });
}
