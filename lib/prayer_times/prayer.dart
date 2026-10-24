import 'wall_time.dart';

/// The five daily prayers, in daily order. Each one is an alarm.
enum Prayer {
  fajr(id: 1, apiKey: 'Fajr', label: 'Fajr', fallbackTime: WallTime(6, 0)),
  dhuhr(id: 2, apiKey: 'Dhuhr', label: 'Dhuhr', fallbackTime: WallTime(13, 0)),
  asr(id: 3, apiKey: 'Asr', label: 'Asr', fallbackTime: WallTime(16, 30)),
  maghrib(
    id: 4,
    apiKey: 'Maghrib',
    label: 'Maghrib',
    fallbackTime: WallTime(19, 0),
  ),
  isha(id: 5, apiKey: 'Isha', label: 'Isha', fallbackTime: WallTime(20, 0));

  const Prayer({
    required this.id,
    required this.apiKey,
    required this.label,
    required this.fallbackTime,
  });

  /// Stable alarm id shared with the native engine. Never renumber: it is the
  /// PendingIntent request code of alarms already armed on the device.
  final int id;

  /// Key of this prayer in AlAdhan's `timings` object.
  final String apiKey;

  final String label;

  /// Rung until AlAdhan times have been fetched for the phone's location.
  final WallTime fallbackTime;

  static Prayer? fromApiKey(String key) {
    for (final prayer in values) {
      if (prayer.apiKey == key) return prayer;
    }
    return null;
  }
}
