import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.neonPink,
        onPrimary: AppColors.primaryText,
        secondary: AppColors.neonTurquoise,
        onSecondary: AppColors.primaryText,
        tertiary: AppColors.neonPurple,
        surface: AppColors.darkSurface,
        onSurface: AppColors.primaryText,
        background: AppColors.darkBackground,
        onBackground: AppColors.primaryText,
        error: AppColors.error,
        onError: AppColors.primaryText,
        outline: AppColors.darkBorder,
        surfaceVariant: AppColors.darkCard,
        onSurfaceVariant: AppColors.secondaryText,
      ),
      
      // Typography
      textTheme: _buildTextTheme(),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.assistant(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 8,
        shadowColor: AppColors.neonPink.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.neonPink.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonPink,
          foregroundColor: AppColors.primaryText,
          elevation: 8,
          shadowColor: AppColors.neonPink.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: GoogleFonts.assistant(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.neonTurquoise,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
          ),
        ),
        labelStyle: GoogleFonts.assistant(
          color: AppColors.secondaryText,
        ),
        hintStyle: GoogleFonts.assistant(
          color: AppColors.disabledText,
        ),
      ),
      
      // Navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.neonPink,
        unselectedItemColor: AppColors.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.assistant(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.assistant(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryText,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.assistant(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
      ),
      displayMedium: GoogleFonts.assistant(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
      ),
      displaySmall: GoogleFonts.assistant(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
      ),
      headlineLarge: GoogleFonts.assistant(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      headlineMedium: GoogleFonts.assistant(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      headlineSmall: GoogleFonts.assistant(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      titleLarge: GoogleFonts.assistant(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      ),
      titleMedium: GoogleFonts.assistant(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      ),
      titleSmall: GoogleFonts.assistant(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      ),
      bodyLarge: GoogleFonts.assistant(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
      ),
      bodyMedium: GoogleFonts.assistant(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
      ),
      bodySmall: GoogleFonts.assistant(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
      ),
      labelLarge: GoogleFonts.assistant(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      ),
      labelMedium: GoogleFonts.assistant(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      ),
      labelSmall: GoogleFonts.assistant(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
      ),
    );
  }
}