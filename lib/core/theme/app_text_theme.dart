import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme get textTheme => const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryTextColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryTextColor,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryTextColor,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.primaryTextColor),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.secondaryTextColor),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryTextColor,
    ),
  );
}
