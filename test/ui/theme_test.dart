import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_alarm/ui/theme/app_colors.dart';
import 'package:prayer_alarm/ui/theme/app_theme.dart';
import 'package:prayer_alarm/ui/theme/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WCAG 2.x contrast ratio.
double contrast(Color a, Color b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final la = luminance(a), lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('palette matches the brief', () {
    expect(AppColors.dark.background, const Color(0xFF0E0E10));
    expect(AppColors.dark.text, const Color(0xFFF5F4F1));
    expect(AppColors.dark.muted, const Color(0xFF8A8A8F));
    expect(AppColors.dark.divider, const Color(0xFF1C1C20));
    expect(AppColors.dark.accentText, const Color(0xFFC8A86B));
    expect(AppColors.light.background, const Color(0xFFFAFAF8));
    expect(AppColors.light.text, const Color(0xFF16161A));
    expect(AppColors.light.muted, const Color(0xFF6E6E76));
    expect(AppColors.light.accentText, const Color(0xFF8A6D2F));
    expect(AppColors.light.accentFill, const Color(0xFFC8A86B));
  });

  for (final (name, c) in [('dark', AppColors.dark), ('light', AppColors.light)]) {
    test('$name: text, muted and accent text pass WCAG AA (4.5:1)', () {
      expect(contrast(c.text, c.background), greaterThan(4.5));
      expect(contrast(c.muted, c.background), greaterThan(4.5));
      expect(contrast(c.accentText, c.background), greaterThan(4.5));
      expect(contrast(c.onAccent, c.accentFill), greaterThan(4.5));
    });
  }

  test('#C8A86B as text on the light background would fail, hence #8A6D2F', () {
    expect(contrast(const Color(0xFFC8A86B), AppColors.light.background), lessThan(4.5));
  });

  test('themes are flat: no elevation, shadow or surface tint', () {
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness);
      expect(theme.shadowColor, Colors.transparent);
      expect(theme.colorScheme.surfaceTint, Colors.transparent);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.dividerTheme.thickness, 1);
    }
  });

  test('dark is the initial theme; the choice is saved', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ThemePreferenceStore(await SharedPreferences.getInstance());

    expect(store.load(), ThemePreference.dark);
    await store.save(ThemePreference.system);
    expect(store.load(), ThemePreference.system);
  });
}
