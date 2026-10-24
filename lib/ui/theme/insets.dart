import 'package:flutter/widgets.dart';

abstract final class Insets {
  /// 56 top / 28 sides / 44 bottom, inside the system bars.
  static const screen = EdgeInsets.fromLTRB(28, 56, 28, 44);

  /// Vertical padding of each alarm row.
  static const rowVertical = 20.0;

  /// Minimum touch target.
  static const minTarget = 48.0;

  static const dismissHeight = 64.0;
  static const dismissRadius = 32.0;
  static const snoozeHeight = 52.0;
}
