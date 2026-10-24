import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../prayer_times/prayer.dart';

/// Which prayer alarms are switched on. Times themselves are not editable:
/// every alarm rings at exactly AlAdhan's time.
class AlarmSettings {
  const AlarmSettings(this.enabled);

  /// Every alarm on, as shipped.
  AlarmSettings.allOn() : enabled = Set.unmodifiable(Prayer.values);

  final Set<Prayer> enabled;

  bool isEnabled(Prayer prayer) => enabled.contains(prayer);

  AlarmSettings withEnabled(Prayer prayer, bool on) => AlarmSettings(
    Set.unmodifiable(on ? {...enabled, prayer} : ({...enabled}..remove(prayer))),
  );
}

class AlarmSettingsStore {
  AlarmSettingsStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'alarm_enabled.v1';

  /// Missing or unreadable data falls back to all alarms on; a prayer absent
  /// from saved data (e.g. added in a later version) is on.
  AlarmSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return AlarmSettings.allOn();
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return AlarmSettings.allOn();
    }
    if (json is! Map) return AlarmSettings.allOn();
    final Map<dynamic, dynamic> saved = json;
    return AlarmSettings(
      Set.unmodifiable(Prayer.values.where((p) => saved[p.apiKey] != false)),
    );
  }

  Future<void> save(AlarmSettings settings) => _prefs.setString(
    _key,
    jsonEncode({for (final p in Prayer.values) p.apiKey: settings.isEnabled(p)}),
  );
}
