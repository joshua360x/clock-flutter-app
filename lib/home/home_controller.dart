import 'dart:async';

import 'package:flutter/material.dart';

import '../alarms/alarm_settings.dart';
import '../prayer_times/prayer.dart';
import '../prayer_times/prayer_schedule.dart';
import '../prayer_times/prayer_times_service.dart';
import '../scripture/scripture_service.dart';
import '../ui/alarm_list/alarm_list_screen.dart';
import '../ui/theme/theme_preference.dart';

/// State behind the alarm list: on/off switches, theme, and the schedule.
class HomeController extends ChangeNotifier {
  HomeController({
    required this.prayerTimes,
    required this.scripture,
    required AlarmSettingsStore alarmSettingsStore,
    required ThemePreferenceStore themeStore,
    DateTime Function()? now,
  }) : _alarmSettingsStore = alarmSettingsStore,
       _themeStore = themeStore,
       _now = now ?? DateTime.now,
       _settings = alarmSettingsStore.load(),
       _theme = themeStore.load();

  final PrayerTimesService prayerTimes;
  final ScriptureService scripture;
  final AlarmSettingsStore _alarmSettingsStore;
  final ThemePreferenceStore _themeStore;
  final DateTime Function() _now;

  AlarmSettings _settings;
  ThemePreference _theme;

  AlarmSettings get settings => _settings;
  ThemePreference get theme => _theme;
  PrayerSchedule get schedule => PrayerSchedule(prayerTimes.timetable);
  DateTime now() => _now();

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

  Future<void> setEnabled(Prayer prayer, bool enabled) async {
    _settings = _settings.withEnabled(prayer, enabled);
    notifyListeners();
    await _alarmSettingsStore.save(_settings);
  }

  Future<void> cycleTheme() async {
    _theme = _theme.next;
    notifyListeners();
    await _themeStore.save(_theme);
  }

  /// Refreshes prayer times and tops up verses; both keep working from their
  /// caches when offline, so failures here are expected and silent.
  Future<void> refresh() async {
    final outcome = await prayerTimes.refresh();
    if (outcome is TimetableUpdated) notifyListeners();
    unawaited(scripture.prefetch());
  }
}
