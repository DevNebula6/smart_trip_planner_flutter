import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Enhanced with more vibrant shades
  static const Color primaryGreen = Color(0xFF2D7A5F);
  static const Color lightGreen = Color(0xFF4ECDC4);
  static const Color darkGreen = Color(0xFF1B5E3F);
  static const Color accentGreen = Color(0xFF00D4AA);
  
  // Secondary Colors
  static const Color orange = Color(0xFFF57C00);
  static const Color lightOrange = Color(0xFFFFB74D);
  static const Color coral = Color(0xFFFF6B6B);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF8F9FA);
  static const Color darkGrey = Color(0xFF424242);
  static const Color mediumGrey = Color(0xFF6B7280);
  
  // Background Colors - More sophisticated
  static const Color backgroundColor = Color(0xFFFAFBFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8F9FA);
  static const Color gradientStart = Color(0xFFE8F5E8);
  static const Color gradientEnd = Color(0xFFD4EDDA);
  
  // Text Colors - Better contrast
  static const Color primaryText = Color(0xFF1A202C);
  static const Color secondaryText = Color(0xFF4A5568);
  static const Color hintText = Color(0xFFA0AEC0);
  static const Color mutedText = Color(0xFF718096);
  
  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFED8936);
  static const Color info = Color(0xFF4299E1);
  
  // Chat Colors
  static const Color userBubble = Color(0xFFF7FAFC);
  static const Color aiBubble = Color(0xFFFFFFFF);
  static const Color chatBackground = Color(0xFFFAFBFC);
  
  // Accent Colors for visual appeal
  static const Color purple = Color(0xFF9F7AEA);
  static const Color teal = Color(0xFF38B2AC);
  static const Color indigo = Color(0xFF667EEA);
}

class AppDimensions {
  // Padding - Enhanced spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  static const double paddingXXXL = 64.0;
  
  // Margin
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 16.0;
  static const double marginL = 24.0;
  static const double marginXL = 32.0;
  static const double marginXXL = 48.0;
  
  // Border Radius - More rounded for modern look
  static const double radiusXS = 6.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusXXXL = 32.0;
  static const double radiusCircular = 50.0;
  
  // Icon Sizes - Larger for better visibility
  static const double iconS = 18.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;
  
  // Button Heights - Larger for better touch
  static const double buttonHeightS = 44.0;
  static const double buttonHeightM = 52.0;
  static const double buttonHeightL = 60.0;
  
  // Avatar Sizes
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 56.0;
  static const double avatarXL = 72.0;
}

class AppShadows {
  static const BoxShadow light = BoxShadow(
    color: Color(0x0F000000),
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );
  
  static const BoxShadow medium = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  );
  
  static const BoxShadow heavy = BoxShadow(
    color: Color(0x25000000),
    offset: Offset(0, 8),
    blurRadius: 24,
    spreadRadius: 0,
  );
  
  static const BoxShadow card = BoxShadow(
    color: Color(0x08000000),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );
  
  static const BoxShadow floating = BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 6),
    blurRadius: 16,
    spreadRadius: -4,
  );
}
