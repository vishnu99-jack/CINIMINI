import 'package:flutter/material.dart';

/// ===============================================================
/// Cinimini Color Palette
/// ---------------------------------------------------------------
/// Centralized color definitions used throughout the application.
/// Never use hard-coded colors inside widgets.
/// ===============================================================

class AppColors {
  AppColors._();

  // ============================================================
  // Brand Colors
  // ============================================================

  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF3B82F6);

  // ============================================================
  // Background Colors
  // ============================================================

  static const Color background = Color(0xFF0D0D12);
  static const Color surface = Color(0xFF16161F);
  static const Color card = Color(0xFF20202A);

  // ============================================================
  // Text Colors
  // ============================================================

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8C2);
  static const Color hint = Color(0xFF8B8B95);

  // ============================================================
  // Status Colors
  // ============================================================

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ============================================================
  // UI Colors
  // ============================================================

  static const Color border = Color(0xFF2C2C35);
  static const Color divider = Color(0xFF25252F);

  // ============================================================
  // Utility Colors
  // ============================================================

  static const Color transparent = Colors.transparent;
}
