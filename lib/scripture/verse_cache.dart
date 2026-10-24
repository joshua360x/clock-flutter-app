import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'verse.dart';

/// Persists prefetched verses, which verse each alarm showed, recently shown
/// references, and any bible-api cool-down, so all of it survives restarts.
///
/// Reads come from SharedPreferences' in-memory copy, so they are instant
/// and safe to call while building the alarm screen.
class VerseCache {
  VerseCache(this._prefs);

  final SharedPreferences _prefs;

  static const _queueKey = 'scripture.queue.v1';
  static const _recentKey = 'scripture.recent.v1';
  static const _assignedKey = 'scripture.assigned.v1';
  static const _cooldownKey = 'scripture.cooldown_until.v1';
  static const recentLimit = 20;

  List<Verse> get queue => _verses(_prefs.getString(_queueKey));

  Future<void> setQueue(List<Verse> verses) => _prefs.setString(
    _queueKey,
    jsonEncode([for (final v in verses) v.toJson()]),
  );

  /// Most recent last.
  List<String> get recentReferences {
    final raw = _decode(_prefs.getString(_recentKey));
    return raw is List ? [for (final r in raw) if (r is String) r] : const [];
  }

  Future<void> markShown(String reference) {
    final recent = [
      ...recentReferences.where((r) => r != reference),
      reference,
    ];
    final trimmed = recent.length > recentLimit
        ? recent.sublist(recent.length - recentLimit)
        : recent;
    return _prefs.setString(_recentKey, jsonEncode(trimmed));
  }

  ({String key, Verse verse})? get assigned {
    final raw = _decode(_prefs.getString(_assignedKey));
    if (raw is! Map || raw['key'] is! String) return null;
    final verse = Verse.fromJson(raw['verse']);
    return verse == null ? null : (key: raw['key'] as String, verse: verse);
  }

  Future<void> assign(String key, Verse verse) => _prefs.setString(
    _assignedKey,
    jsonEncode({'key': key, 'verse': verse.toJson()}),
  );

  DateTime? get cooldownUntil =>
      DateTime.tryParse(_prefs.getString(_cooldownKey) ?? '');

  Future<void> setCooldownUntil(DateTime until) =>
      _prefs.setString(_cooldownKey, until.toUtc().toIso8601String());

  static List<Verse> _verses(String? raw) {
    final list = _decode(raw);
    if (list is! List) return const [];
    return [
      for (final v in list)
        if (Verse.fromJson(v) case final verse?) verse,
    ];
  }

  static Object? _decode(String? raw) {
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
