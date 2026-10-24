import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/alarms/alarm_settings.dart';
import 'package:prayer_alarm/prayer_times/calculation_method.dart';
import 'package:prayer_alarm/prayer_times/geo_point.dart';
import 'package:prayer_alarm/prayer_times/prayer.dart';
import 'package:prayer_alarm/prayer_times/timetable.dart';
import 'package:prayer_alarm/prayer_times/timetable_store.dart';
import 'package:prayer_alarm/prayer_times/wall_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

Timetable _timetable() => Timetable(
  location: const GeoPoint(40.7128, -74.006),
  method: CalculationMethods.isna,
  school: AsrSchool.standard,
  timeZone: 'America/New_York',
  fetchedAt: DateTime.utc(2026, 10, 25, 12),
  days: [
    PrayerDay(
      date: DateTime.utc(2026, 10, 25),
      times: {
        for (final (i, p) in Prayer.values.indexed)
          p: PrayerTime(
            at: DateTime.utc(2026, 10, 25, 9 + i * 3, 41),
            wall: WallTime(5 + i * 3, 41),
          ),
      },
    ),
  ],
);

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group('TimetableStore', () {
    test('round-trips a timetable', () async {
      final store = TimetableStore(await prefsWith({}));

      await store.save(_timetable());
      final loaded = store.load()!;

      expect(loaded.method, CalculationMethods.isna);
      expect(loaded.timeZone, 'America/New_York');
      expect(loaded.location.latitude, 40.7128);
      expect(loaded.days.single.times[Prayer.isha]!.wall, const WallTime(17, 41));
      expect(
        loaded.days.single.times[Prayer.isha]!.at,
        DateTime.utc(2026, 10, 25, 21, 41),
      );
    });

    test('nothing saved: null', () async {
      expect(TimetableStore(await prefsWith({})).load(), isNull);
    });

    test('corrupt or old-version data reads as empty instead of crashing', () async {
      for (final raw in ['not json', '{"v":2}', '{"v":1,"days":"x"}', '[]']) {
        final store = TimetableStore(await prefsWith({'prayer_timetable.v1': raw}));
        expect(store.load(), isNull, reason: raw);
      }
    });
  });

  group('AlarmSettingsStore', () {
    test('ships with every alarm on', () async {
      final settings = AlarmSettingsStore(await prefsWith({})).load();

      expect(settings.enabled, Prayer.values.toSet());
    });

    test('a switched-off alarm stays off after restart', () async {
      final prefs = await prefsWith({});
      await AlarmSettingsStore(prefs).save(
        AlarmSettings.allOn().withEnabled(Prayer.dhuhr, false),
      );

      final reloaded = AlarmSettingsStore(prefs).load();

      expect(reloaded.isEnabled(Prayer.dhuhr), isFalse);
      expect(reloaded.isEnabled(Prayer.fajr), isTrue);
    });

    test('corrupt data falls back to all on', () async {
      final store = AlarmSettingsStore(
        await prefsWith({'alarm_enabled.v1': '{broken'}),
      );

      expect(store.load().enabled, Prayer.values.toSet());
    });
  });
}
