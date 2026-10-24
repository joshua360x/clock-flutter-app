import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's theme choice. Dark ships as the initial value; System follows
/// the phone's setting.
enum ThemePreference {
  dark('Dark', ThemeMode.dark),
  light('Light', ThemeMode.light),
  system('System', ThemeMode.system);

  const ThemePreference(this.label, this.mode);
  final String label;
  final ThemeMode mode;

  ThemePreference get next => values[(index + 1) % values.length];
}

class ThemePreferenceStore {
  ThemePreferenceStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'theme_preference.v1';

  ThemePreference load() => ThemePreference.values.firstWhere(
    (p) => p.name == _prefs.getString(_key),
    orElse: () => ThemePreference.dark,
  );

  Future<void> save(ThemePreference preference) =>
      _prefs.setString(_key, preference.name);
}
