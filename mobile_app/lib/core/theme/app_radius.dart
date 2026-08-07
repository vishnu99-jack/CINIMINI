import 'package:flutter/widgets.dart';

/// ===============================================================
/// Cinimini Radius System
/// ---------------------------------------------------------------
/// Standard border radius values used throughout the app.
/// Never use BorderRadius.circular() directly inside widgets.
/// ===============================================================

class AppRadius {
  AppRadius._();

  // Radius Values
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  // Ready-to-use BorderRadius objects
  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));

  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));

  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));

  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(xl));

  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));
}
