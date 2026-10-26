import '../audio/alarm_sound.dart';
import '../prayer_times/prayer.dart';
import '../prayer_times/prayer_schedule.dart';
import 'alarm_settings.dart';

/// The schedule handed to the native engine on every change. The engine
/// stores it and re-arms from it on its own (after each ring, on boot, on
/// time or timezone changes), so it carries everything needed: exact
/// AlAdhan times, the fallback clock time and its zone, and the sound.
///
/// Shape is pinned by test/fixtures/schedule_payload_sample.json, which the
/// Kotlin parser (Schedule.kt) is tested against too.
Map<String, Object?> buildSchedulePayload({
  required PrayerSchedule schedule,
  required AlarmSettings settings,
  required AlarmSoundResolver sounds,
  required DateTime now,
  int snoozeMinutes = 10,
  int ringTimeoutMinutes = 10,
  int maxInstants = 62,
}) => {
  'version': 1,
  'snoozeMinutes': snoozeMinutes,
  'ringTimeoutMinutes': ringTimeoutMinutes,
  'fallbackSound': bellSound.toWire(),
  'alarms': [
    for (final prayer in Prayer.values)
      {
        'id': prayer.id,
        'key': prayer.name,
        'label': prayer.label,
        'enabled': settings.isEnabled(prayer),
        'instants': [
          for (final at in schedule.fetchedAfter(prayer, now).take(maxInstants))
            at.millisecondsSinceEpoch,
        ],
        'fallback': schedule.fallbackTime(prayer).toString(),
        'zone': schedule.fallbackTimeZone,
        'sound': sounds.soundFor(prayer).toWire(),
      },
  ],
};
