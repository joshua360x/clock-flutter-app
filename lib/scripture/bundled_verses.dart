import 'dart:convert';

import 'package:flutter/services.dart';

import 'verse.dart';

const bundledVersesAsset = 'assets/scripture/verses.json';

/// The offline KJV verses shipped in the app. Returns an empty list rather
/// than throwing; callers fall back to [fallbackVerse].
Future<List<Verse>> loadBundledVerses(AssetBundle bundle) async {
  try {
    return parseBundledVerses(await bundle.loadString(bundledVersesAsset));
  } on Exception {
    return const [];
  }
}

List<Verse> parseBundledVerses(String json) {
  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException {
    return const [];
  }
  final verses = decoded is Map ? decoded['verses'] : null;
  if (verses is! List) return const [];
  return List.unmodifiable([
    for (final v in verses)
      if (Verse.fromJson(v) case final verse?) verse,
  ]);
}
