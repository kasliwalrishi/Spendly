import 'package:flutter/material.dart';

class AppColors {
  // Core colors
  static const primary = Color.fromARGB(255, 46, 196, 182);
  static const secondary = Color(0xFFFFBF69);
  static const background = Colors.white;
  static const surface = Colors.white;
  static const error = Color(0xFFFF6B6B);

  // Text colors
  static const textPrimary = Color(0xFF2B2F42);
  static const textSecondary = Color(0xFF6B7280);

  // Gradient colors
  static const gradientStart = Color(0xFF2EC4B6);
  static const gradientEnd = Color(0xFFFFBF69);

  static const lightColors = ColorScheme.light(
    primary: primary,
    secondary: secondary,
    surface: surface,
    error: error,
    onPrimary: Colors.white,
    onSecondary: textPrimary,
    onSurface: textPrimary,
    onError: Colors.white,
  );

  static const darkColors = ColorScheme.dark(
    primary: primary,
    secondary: secondary,
    surface: Color(0xFF1E1E1E),
    error: error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  );
}
