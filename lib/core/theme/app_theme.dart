import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.white,
        background: AppColors.backgroundColor,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onBackground: AppColors.primaryText,
        onError: AppColors.white,
        surfaceTint: AppColors.primaryVeryLight,
        outline: AppColors.grey300,
        outlineVariant: AppColors.grey200,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      cardTheme: _buildCardTheme(),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(),
    );
  }
  
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
        letterSpacing: -0.25,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
        letterSpacing: -0.25,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
        letterSpacing: -0.25,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: AppColors.primaryText,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.primaryText,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.secondaryText,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.hintText,
      ),
    );
  }
  
  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.primaryText,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primaryText,
      ),
    );
  }
  
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shadowColor: AppColors.shadowPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
  
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        borderSide: BorderSide(color: AppColors.grey200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingM,
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.hintText,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.inter(
        color: AppColors.secondaryText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
  
  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      color: AppColors.cardBackground,
      shadowColor: AppColors.black.withOpacity(0.1),
    );
  }
  
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }
  
  // Additional helper method for creating gradient buttons
  static BoxDecoration gradientButtonDecoration({
    Gradient? gradient,
    double borderRadius = 16.0,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppGradients.primary,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: boxShadow ?? AppShadows.card,
    );
  }
  
  // Helper method for glassmorphism effect
  static BoxDecoration glassDecoration({
    double borderRadius = 16.0,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: 1.5,
      ),
      boxShadow: AppShadows.card,
    );
  }
}
