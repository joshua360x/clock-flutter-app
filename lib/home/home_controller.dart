import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../alarms/alarm_engine.dart';
import '../alarms/alarm_settings.dart';
import '../alarms/schedule_payload.dart';
import '../audio/alarm_sound.dart';
import '../prayer_times/prayer.dart';
import '../prayer_times/prayer_schedule.dart';
import '../prayer_times/prayer_times_service.dart';
import '../scripture/scripture_service.dart';
import '../scripture/verse.dart';
import '../ui/alarm_list/alarm_list_screen.dart';
import '../ui/theme/theme_preference.dart';

/// App state: alarm switches, theme, the schedule, what is ringing, and
/// what still needs a permission. Every change to the schedule is synced to
/// the native engine, which arms and rings the alarms on its own.
class HomeController extends ChangeNotifier {
  HomeController({
    required this.prayerTimes,
    required this.scripture,
    required this.engine,
    required this.sounds,
    required AlarmSettingsStore alarmSettingsStore,
    required ThemePreferenceStore themeStore,
    required SharedPreferences prefs,
    DateTime Function()? now,
  }) : _alarmSettingsStore = alarmSettingsStore,
       _themeStore = themeStore,
       _prefs = prefs,
       _now = now ?? DateTime.now,
       _settings = alarmSettingsStore.load(),
       _theme = themeStore.load();

  final PrayerTimesService prayerTimes;
  final ScriptureService scripture;
  final AlarmEngine engine;
  final AlarmSoundResolver sounds;
  final AlarmSettingsStore _alarmSettingsStore;
  final ThemePreferenceStore _themeStore;
  final SharedPreferences _prefs;
  final DateTime Function() _now;

  static const testDelay = Duration(seconds: 10);
  static const _onboardedKey = 'onboarded.v1';

  AlarmSettings _settings;
  ThemePreference _theme;
  RingingAlarm? _ringing;
  Set<ReliabilityItem> _missing = const {};
  DateTime? _testRingsAt;
  StreamSubscription<RingingAlarm?>? _ringingSub;

  AlarmSettings get settings => _settings;
  ThemePreference get theme => _theme;
  RingingAlarm? get ringing => _ringing;
  Set<ReliabilityItem> get missing => _missing;
  PrayerSchedule get schedule => PrayerSchedule(prayerTimes.timetable);
  DateTime now() => _now();

  /// Verse for the alarm ringing now (instant, offline, never blank).
  Verse? get ringingVerse =>
      _ringing == null ? null : scripture.verseForAlarm(_ringing!.ringKey);

  /// Shown under the footer while a test alarm is pending.
  String? get testNote {
    final at = _testRingsAt;
    if (at == null || !_now().isBefore(at)) return null;
    return 'Test alarm rings in ${testDelay.inSeconds} seconds. Lock the '
        'phone to see it over the lock screen.';
  }

  List<AlarmRowData> rows() {
    final now = _now();
    final schedule = this.schedule;
    final due = schedule.nextDue(_settings.enabled, now);
    return [
      for (final prayer in Prayer.values)
        AlarmRowData(
          prayer: prayer,
          time: TimeOfDay.fromDateTime(schedule.nextRing(prayer, now).toLocal()),
          enabled: _settings.isEnabled(prayer),
          isNextDue: due?.prayer == prayer,
        ),
    ];
  }

  String get sourceLine {
    final timetable = prayerTimes.timetable;
    if (timetable == null) {
      return 'Approximate times until your location is available';
    }
    return 'AlAdhan · ${timetable.method.name}';
  }

  /// First launch asks for notifications and location (the two prompts the
  /// alarms need most), then everything refreshes.
  Future<void> start() async {
    _ringingSub = engine.ringingChanges.listen((ringing) {
      _ringing = ringing;
      notifyListeners();
    });
    _ringing = await _guard(engine.currentRinging, null);
    notifyListeners();

    if (_prefs.getBool(_onboardedKey) != true) {
      await _prefs.setBool(_onboardedKey, true);
      for (final item in [ReliabilityItem.notifications, ReliabilityItem.location]) {
        if ((await _guard(engine.missingReliability, const <ReliabilityItem>{})).contains(item)) {
          await _guard(() => engine.fix(item), false);
        }
      }
    }
    await refresh();
  }

  /// On launch and on every resume: permissions may have changed in system
  /// settings, the phone may have moved, and verses can be topped up.
  Future<void> refresh() async {
    _missing = await _guard(engine.missingReliability, const <ReliabilityItem>{});
    notifyListeners();
    await prayerTimes.refresh();
    await _sync();
    notifyListeners();
    unawaited(scripture.prefetch());
  }

  Future<void> setEnabled(Prayer prayer, bool enabled) async {
    _settings = _settings.withEnabled(prayer, enabled);
    notifyListeners();
    await _alarmSettingsStore.save(_settings);
    await _sync();
  }

  Future<void> cycleTheme() async {
    _theme = _theme.next;
    notifyListeners();
    await _themeStore.save(_theme);
  }

  Future<void> fix(ReliabilityItem item) async {
    final fixed = await _guard(() => engine.fix(item), false);
    _missing = await _guard(engine.missingReliability, _missing);
    notifyListeners();
    if (fixed && item == ReliabilityItem.location) await refresh();
  }

  /// Rings the next prayer's alarm (its label and sound) shortly, through
  /// the real engine, so sound and lock-screen behaviour can be checked.
  Future<void> testAlarm() async {
    final due = schedule.nextDue(_settings.enabled, _now());
    final prayer = due?.prayer ?? Prayer.fajr;
    await _sync();
    await _guard(() => engine.testAlarm(alarmId: prayer.id, delay: testDelay), null);
    _testRingsAt = _now().add(testDelay);
    notifyListeners();
  }

  Future<void> dismiss() async {
    _ringing = null;
    notifyListeners();
    await _guard(engine.dismiss, null);
  }

  Future<void> snooze() async {
    _ringing = null;
    notifyListeners();
    await _guard(engine.snooze, null);
  }

  Future<void> _sync() => _guard(
    () => engine.sync(
      buildSchedulePayload(
        schedule: schedule,
        settings: _settings,
        sounds: sounds,
        now: _now(),
      ),
    ),
    null,
  );

  /// The engine is a platform channel: failures (e.g. no native side in a
  /// test, or an Android quirk) must never break the UI.
  Future<T> _guard<T>(Future<T> Function() call, T fallback) async {
    try {
      return await call();
    } on Exception catch (e) {
      debugPrint('alarm engine: $e');
      return fallback;
    }
  }

  @override
  void dispose() {
    _ringingSub?.cancel();
    super.dispose();
  }
}
