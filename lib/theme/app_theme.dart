import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand palette
  static const deepest = Color(0xFF3E0703);
  static const dark = Color(0xFF660B05);
  static const medium = Color(0xFF8C1007);
  static const cream = Color(0xFFFFF0C4);

  // Dark theme surfaces
  static const darkBg = Color(0xFF1F0201);
  static const darkSurface = Color(0xFF3E0703);
  static const darkButton = Color(0xFF660B05);
  static const darkOperator = Color(0xFF8C1007);
  static const darkShadow = Color(0xFF1A0100);
  static const darkSci = Color(0xFF4A0904);

  // Light theme surfaces
  static const lightBg = Color(0xFFFFF0C4);
  static const lightSurface = Color(0xFFFFE5A0);
  static const lightButton = Color(0xFF8C1007);
  static const lightOperator = Color(0xFF660B05);
  static const lightShadow = Color(0xFF3E0703);
  static const lightSci = Color(0xFFAA1A10);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primary) => TextTheme(
        displayLarge: GoogleFonts.spaceMono(
            color: primary, fontWeight: FontWeight.bold, fontSize: 48),
        displayMedium: GoogleFonts.spaceMono(
            color: primary, fontWeight: FontWeight.bold, fontSize: 32),
        bodyLarge: GoogleFonts.spaceMono(color: primary, fontSize: 16),
        bodyMedium: GoogleFonts.spaceMono(color: primary, fontSize: 14),
        labelLarge: GoogleFonts.spaceMono(
            color: primary, fontWeight: FontWeight.bold, fontSize: 20),
        labelSmall: GoogleFonts.spaceMono(color: primary, fontSize: 11),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        textTheme: _buildTextTheme(AppColors.cream),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cream,
          secondary: AppColors.medium,
          surface: AppColors.darkSurface,
          onPrimary: AppColors.deepest,
          onSurface: AppColors.cream,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBg,
          foregroundColor: AppColors.cream,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: AppColors.cream),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        textTheme: _buildTextTheme(AppColors.deepest),
        colorScheme: const ColorScheme.light(
          primary: AppColors.deepest,
          secondary: AppColors.medium,
          surface: AppColors.lightSurface,
          onPrimary: AppColors.cream,
          onSurface: AppColors.deepest,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBg,
          foregroundColor: AppColors.deepest,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: AppColors.deepest),
      );
}
