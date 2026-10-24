import 'package:flutter/painting.dart';

/// Type scale. Colours are applied by the widgets from AppColors.
///
/// Inter everywhere, Lora only for scripture: the single serif is what makes
/// the verse read as the point of the screen. Both are variable fonts, so
/// weights are set with FontVariation (fontWeight alone does not move a
/// variable font's axis).
abstract final class AppText {
  static const inter = 'Inter';
  static const lora = 'Lora';

  static TextStyle _inter(double size, double weight, {double? opsz}) =>
      TextStyle(
        fontFamily: inter,
        fontSize: size,
        fontWeight: FontWeight.values[(weight ~/ 100) - 1],
        fontVariations: [
          FontVariation.weight(weight),
          // Inter's display cut (opsz 32) at large sizes, text cut below.
          FontVariation.opticalSize(opsz ?? size.clamp(14, 32).toDouble()),
        ],
      );

  /// Alarm screen clock: 76px, weight 200, letter-spacing -0.035em.
  static final clock = _inter(
    76,
    200,
  ).copyWith(letterSpacing: -0.035 * 76, height: 1.0);

  /// AM/PM beside the clock when the phone uses 12-hour time.
  static final clockPeriod = _inter(20, 400).copyWith(letterSpacing: 0.4);

  /// Scripture body: Lora 23px, line-height 1.58.
  static const scripture = TextStyle(
    fontFamily: lora,
    fontSize: 23,
    height: 1.58,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
  );

  /// Scripture reference under the verse.
  static final reference = _inter(14, 500).copyWith(letterSpacing: 0.2);

  /// Section labels: 12px, weight 500, letter-spacing 0.18em, uppercase
  /// (the uppercase is applied to the string by SectionLabel).
  static final sectionLabel = _inter(
    12,
    500,
  ).copyWith(letterSpacing: 0.18 * 12, height: 1.2);

  /// Alarm list: the time in each row.
  static final rowTime = _inter(
    34,
    300,
  ).copyWith(letterSpacing: -0.02 * 34, height: 1.1);

  /// Alarm list: prayer name under the time.
  static final rowLabel = _inter(15, 400);

  static final body = _inter(15, 400).copyWith(height: 1.45);
  static final small = _inter(13, 400).copyWith(height: 1.4);
  static final button = _inter(17, 500).copyWith(letterSpacing: 0.2);
}
