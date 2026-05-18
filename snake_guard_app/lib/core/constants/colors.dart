import 'package:flutter/material.dart';

class AppColors {
  // Emergency Red Palette
  static const Color primaryRed = Color(0xFFE50914);
  static const Color darkRed = Color(0xFF8B0000);
  static const Color lightRed = Color(0xFFFF4C4C);

  // Background and Surfaces
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusCritical = Color(0xFFE50914);
  static const Color statusModerate = Color(0xFFFF9800);
  static const Color statusLow = Color(0xFF4CAF50);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFFB3B3B3);
  static const Color textPrimaryDark = Color(0xFF121212);
  static const Color textSecondaryDark = Color(0xFF757575);

  // Gradients
  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [primaryRed, darkRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
