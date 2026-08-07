import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_constants.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    fontFamily: AppTextStyles.fontFamily,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    // ==========================================================
    // Typography
    // ==========================================================
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,

      headlineLarge: AppTextStyles.screenTitle,
      headlineMedium: AppTextStyles.sectionTitle,

      titleLarge: AppTextStyles.cardTitle,

      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,

      labelLarge: AppTextStyles.buttonMedium,

      bodySmall: AppTextStyles.bodySmall,
    ),

    // ==========================================================
    // AppBar
    // ==========================================================
    appBarTheme:  AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTextStyles.screenTitle,
    ),

    // ==========================================================
    // Card
    // ==========================================================
  cardTheme: CardThemeData(
      elevation: AppConstants.cardElevation,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.large,
        side: BorderSide(
          color: AppColors.border.withOpacity(AppConstants.cardBorderOpacity),
        ),
      ),
    ),

    // ==========================================================
    // Filled Button
    // ==========================================================
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: AppConstants.buttonElevation,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.buttonMedium,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    ),

    // ==========================================================
    // Outlined Button
    // ==========================================================
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    ),

    // ==========================================================
    // Text Button
    // ==========================================================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),

    // ==========================================================
    // Input Decoration
    // ==========================================================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,

      labelStyle: AppTextStyles.inputLabel,
      hintStyle: AppTextStyles.inputHint,

      border: OutlineInputBorder(
        borderRadius: AppRadius.medium,
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.medium,
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.medium,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),

    // ==========================================================
    // Divider
    // ==========================================================
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),

    // ==========================================================
    // Bottom Navigation
    // ==========================================================
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withOpacity(0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }

        return const IconThemeData(color: AppColors.textSecondary);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.navigationLabel.copyWith(
            color: AppColors.primary,
          );
        }

        return AppTextStyles.navigationLabel;
      }),
    ),

    // ==========================================================
    // Bottom Sheet
    // ==========================================================
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    // ==========================================================
    // SnackBar
    // ==========================================================
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: AppTextStyles.bodyMedium,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      behavior: SnackBarBehavior.floating,
    ),

    // ==========================================================
    // Icon Theme
    // ==========================================================
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
  );
}
