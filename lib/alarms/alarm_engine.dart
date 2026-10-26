/// An alarm ringing right now (reported by the native engine).
class RingingAlarm {
  const RingingAlarm({
    required this.alarmId,
    required this.key,
    required this.label,
    required this.scheduledAt,
    required this.isTest,
  });

  final int alarmId;

  /// Prayer key, e.g. "fajr".
  final String key;
  final String label;
  final DateTime scheduledAt;
  final bool isTest;

  /// Identifies this ring, so reopening it shows the same verse.
  String get ringKey => '$key@${scheduledAt.toUtc().toIso8601String()}';

  static RingingAlarm? fromMap(Object? map) {
    if (map is! Map) return null;
    final id = map['alarmId'], key = map['key'], label = map['label'], at = map['at'];
    if (id is! int || key is! String || label is! String || at is! int) return null;
    return RingingAlarm(
      alarmId: id,
      key: key,
      label: label,
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(at),
      isTest: map['kind'] == 'test',
    );
  }
}

/// Things that can stop an alarm from ringing on time, on screen, audibly.
/// Names match device/Reliability.kt.
enum ReliabilityItem {
  notifications(
    'notifications',
    'Allow notifications',
    'Alarms can’t appear on screen without them.',
  ),
  exactAlarms(
    'exactAlarms',
    'Allow alarms & reminders',
    'Without it, alarms may ring a few minutes late.',
  ),
  fullScreen(
    'fullScreen',
    'Allow full-screen alarms',
    'So the alarm appears over the lock screen.',
  ),
  batteryOptimization(
    'batteryOptimization',
    'Don’t optimise battery for this app',
    'Stops the phone from delaying or cancelling alarms.',
  ),
  location(
    'location',
    'Allow location',
    'Prayer times come from AlAdhan for where you are.',
  ),
  alarmVolume(
    'alarmVolume',
    'Alarm volume is off',
    'Turn it up so the alarm can be heard.',
  );

  const ReliabilityItem(this.wireName, this.title, this.detail);
  final String wireName;
  final String title;
  final String detail;

  static ReliabilityItem? fromWire(Object? name) {
    for (final item in values) {
      if (item.wireName == name) return item;
    }
    return null;
  }
}

/// The native alarm engine (android/.../NativeBridge.kt).
abstract interface class AlarmEngine {
  /// Stores the schedule natively and re-arms every alarm from it.
  Future<void> sync(Map<String, Object?> payload);

  Future<RingingAlarm?> currentRinging();

  /// Emits when an alarm starts or stops ringing (including from the
  /// notification's buttons).
  Stream<RingingAlarm?> get ringingChanges;

  Future<void> dismiss();
  Future<void> snooze();

  /// Rings [alarmId]'s alarm (its label and sound) after [delay].
  Future<void> testAlarm({required int alarmId, required Duration delay});

  Future<Set<ReliabilityItem>> missingReliability();

  /// Asks for the permission or opens the settings screen for [item].
  /// Returns whether it is fixed now.
  Future<bool> fix(ReliabilityItem item);
}
