import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  //==============================================================
  // Font Family
  //==============================================================

  static const String fontFamily = "Poppins";

  //==============================================================
  // Base Style
  //==============================================================

  static const TextStyle _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: 0.2,
  );

  //==============================================================
  // APP LOGO
  //==============================================================

  static final TextStyle logoWhite = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
  );

  static final TextStyle logoPurple = logoWhite.copyWith(
    color: AppColors.primary,
  );

  //==============================================================
  // DISPLAY
  //==============================================================

  static final TextStyle displayLarge = _base.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle displayMedium = _base.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle displaySmall = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  //==============================================================
  // SCREEN
  //==============================================================

  static final TextStyle screenTitle = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle screenSubtitle = _base.copyWith(
    fontSize: 15,
    color: AppColors.textSecondary,
  );

  //==============================================================
  // SECTION
  //==============================================================

  static final TextStyle sectionTitle = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle sectionSubtitle = _base.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static final TextStyle seeAll = _base.copyWith(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
  );

  //==============================================================
  // HERO BANNER
  //==============================================================

  static final TextStyle heroTitle = _base.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle heroSubtitle = _base.copyWith(
    fontSize: 14,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  //==============================================================
  // VIDEO
  //==============================================================

  static final TextStyle videoTitle = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle creatorName = _base.copyWith(
    fontSize: 13,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle metadata = _base.copyWith(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static final TextStyle durationBadge = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  //==============================================================
  // CARD
  //==============================================================

  static final TextStyle cardTitle = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle cardSubtitle = _base.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static final TextStyle cardCaption = _base.copyWith(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  //==============================================================
  // BODY
  //==============================================================

  static final TextStyle bodyLarge = _base.copyWith(fontSize: 16);

  static final TextStyle bodyMedium = _base.copyWith(fontSize: 14);

  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  //==============================================================
  // BUTTONS
  //==============================================================

  static final TextStyle buttonLarge = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle buttonMedium = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle buttonSmall = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  //==============================================================
  // NAVIGATION
  //==============================================================

  static final TextStyle navigationLabel = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  //==============================================================
  // INPUT
  //==============================================================

  static final TextStyle inputLabel = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle inputHint = _base.copyWith(
    fontSize: 14,
    color: AppColors.textMuted,
  );

  static final TextStyle inputText = _base.copyWith(fontSize: 15);

  //==============================================================
  // DIALOG
  //==============================================================

  static final TextStyle dialogTitle = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle dialogBody = _base.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  //==============================================================
  // CHIP
  //==============================================================

  static final TextStyle chipText = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  //==============================================================
  // COMMENTS
  //==============================================================

  static final TextStyle commentUser = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle commentBody = _base.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  //==============================================================
  // NOTIFICATION
  //==============================================================

  static final TextStyle notificationTitle = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle notificationBody = _base.copyWith(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  //==============================================================
  // STATUS
  //==============================================================

  static final TextStyle success = _base.copyWith(
    color: AppColors.success,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle warning = _base.copyWith(
    color: AppColors.warning,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle error = _base.copyWith(
    color: AppColors.error,
    fontWeight: FontWeight.w600,
  );
}
