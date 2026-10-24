import 'package:flutter/material.dart';

/// Colour tokens. Widgets read these via `AppColors.of(context)`; no colour
/// literals elsewhere.
///
/// The accent is rationed: at most twice per screen (the section label and
/// the primary action), and on the alarm list only the next alarm due.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.text,
    required this.muted,
    required this.divider,
    required this.accentText,
    required this.accentFill,
    required this.onAccent,
  });

  final Color background;
  final Color text;
  final Color muted;
  final Color divider;

  /// Accent for text on [background].
  final Color accentText;

  /// Accent as a fill (primary button), with [onAccent] text on it.
  final Color accentFill;
  final Color onAccent;

  /// Default: the 6 AM alarm fires in a dark room.
  static const dark = AppColors(
    background: Color(0xFF0E0E10),
    text: Color(0xFFF5F4F1),
    muted: Color(0xFF8A8A8F),
    divider: Color(0xFF1C1C20),
    accentText: Color(0xFFC8A86B),
    accentFill: Color(0xFFC8A86B),
    onAccent: Color(0xFF0E0E10),
  );

  static const light = AppColors(
    background: Color(0xFFFAFAF8),
    text: Color(0xFF16161A),
    muted: Color(0xFF6E6E76),
    // Not in the brief; a hairline at the same weight as the dark divider.
    divider: Color(0xFFE6E6E1),
    // #C8A86B fails contrast on near-white, so accent text darkens.
    accentText: Color(0xFF8A6D2F),
    accentFill: Color(0xFFC8A86B),
    onAccent: Color(0xFF16161A),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? background,
    Color? text,
    Color? muted,
    Color? divider,
    Color? accentText,
    Color? accentFill,
    Color? onAccent,
  }) => AppColors(
    background: background ?? this.background,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    divider: divider ?? this.divider,
    accentText: accentText ?? this.accentText,
    accentFill: accentFill ?? this.accentFill,
    onAccent: onAccent ?? this.onAccent,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      accentFill: Color.lerp(accentFill, other.accentFill, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}
