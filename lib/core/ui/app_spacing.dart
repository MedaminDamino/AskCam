import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double zero = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);
  static EdgeInsets only({
    double left = zero,
    double top = zero,
    double right = zero,
    double bottom = zero,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
}
