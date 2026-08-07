import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ===============================================================
/// Cinimini Typography System
/// ---------------------------------------------------------------
/// Centralized typography used throughout the application.
/// Never create TextStyle directly inside widgets.
/// Always use AppTextStyles.
/// ===============================================================

class AppTextStyles {
  AppTextStyles._();

  // ============================================================
  // Font Family
  // ============================================================

  static const String fontFamily = 'Poppins';

  // ============================================================
  // Base Style
  // ============================================================

  static const TextStyle _baseStyle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // ============================================================
  // Display Styles (Splash / Hero)
  // ============================================================

  static final TextStyle displayLarge = _baseStyle.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle displayMedium = _baseStyle.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle displaySmall = _baseStyle.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  // ============================================================
  // Screen Titles
  // ============================================================

  static final TextStyle screenTitle = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle screenSubtitle = _baseStyle.copyWith(
    fontSize: 16,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  // ============================================================
  // Section Titles
  // ============================================================

  static final TextStyle sectionTitle = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle sectionSubtitle = _baseStyle.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  // ============================================================
  // Video Titles
  // ============================================================

  static final TextStyle videoTitle = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // ============================================================
  // Card Styles
  // ============================================================

  static final TextStyle cardTitle = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle cardSubtitle = _baseStyle.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle cardCaption = _baseStyle.copyWith(
    fontSize: 12,
    color: AppColors.hint,
    fontWeight: FontWeight.w500,
  );

  // ============================================================
  // Body Text
  // ============================================================

  static final TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  // ============================================================
  // Buttons
  // ============================================================

  static final TextStyle buttonLarge = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle buttonMedium = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle buttonSmall = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ============================================================
  // Navigation
  // ============================================================

  static final TextStyle navigationLabel = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ============================================================
  // Input Fields
  // ============================================================

  static final TextStyle inputLabel = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle inputHint = _baseStyle.copyWith(
    fontSize: 14,
    color: AppColors.hint,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle inputText = _baseStyle.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  // ============================================================
  // Dialog
  // ============================================================

  static final TextStyle dialogTitle = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle dialogBody = _baseStyle.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  // ============================================================
  // Chips
  // ============================================================

  static final TextStyle chipText = _baseStyle.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // ============================================================
  // Metadata
  // ============================================================

  static final TextStyle metadata = _baseStyle.copyWith(
    fontSize: 12,
    color: AppColors.hint,
    fontWeight: FontWeight.w500,
  );

  // ============================================================
  // Creator
  // ============================================================

  static final TextStyle creatorName = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ============================================================
  // Comments
  // ============================================================

  static final TextStyle commentUser = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle commentBody = _baseStyle.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  // ============================================================
  // Notifications
  // ============================================================

  static final TextStyle notificationTitle = _baseStyle.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle notificationBody = _baseStyle.copyWith(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  // ============================================================
  // Status
  // ============================================================

  static final TextStyle success = _baseStyle.copyWith(
    color: AppColors.success,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle warning = _baseStyle.copyWith(
    color: AppColors.warning,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle error = _baseStyle.copyWith(
    color: AppColors.error,
    fontWeight: FontWeight.w600,
  );
}
