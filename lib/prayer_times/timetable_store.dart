import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'timetable.dart';

/// Keeps the last fetched timetable so alarms work offline.
class TimetableStore {
  TimetableStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'prayer_timetable.v1';

  /// Null when nothing was saved or the saved data is unreadable.
  Timetable? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return Timetable.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  Future<void> save(Timetable timetable) =>
      _prefs.setString(_key, jsonEncode(timetable.toJson()));
}
