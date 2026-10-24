import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// Flat by construction: no elevation, shadows or surface tint anywhere, so
/// space and type carry the hierarchy.
ThemeData buildAppTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.accentFill,
    onPrimary: c.onAccent,
    secondary: c.text,
    onSecondary: c.background,
    error: c.text,
    onError: c.background,
    surface: c.background,
    onSurface: c.text,
    onSurfaceVariant: c.muted,
    outline: c.muted,
    outlineVariant: c.divider,
    surfaceTint: Colors.transparent,
    shadow: Colors.transparent,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: AppText.inter,
  );

  return base.copyWith(
    scaffoldBackgroundColor: c.background,
    canvasColor: c.background,
    shadowColor: Colors.transparent,
    splashFactory: InkRipple.splashFactory,
    extensions: [c],
    textTheme: base.textTheme.apply(
      bodyColor: c.text,
      displayColor: c.text,
      fontFamily: AppText.inter,
    ),
    dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    // Toggles stay neutral: the accent is reserved for the next alarm due.
    switchTheme: SwitchThemeData(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.background : c.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.text : Colors.transparent,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.text : c.muted,
      ),
      trackOutlineWidth: const WidgetStatePropertyAll(1),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.muted,
        minimumSize: const Size(48, 48),
        textStyle: AppText.body,
        elevation: 0,
      ),
    ),
  );
}
