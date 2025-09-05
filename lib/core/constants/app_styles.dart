import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF2D7A5F);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E3F);
  
  // Secondary Colors
  static const Color orange = Color(0xFFF57C00);
  static const Color lightOrange = Color(0xFFFFB74D);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  static const Color hintText = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Chat Colors
  static const Color userBubble = Color(0xFFF5F5F5);
  static const Color aiBubble = Color(0xFFFFFFFF);
  static const Color chatBackground = Color(0xFFF8F9FA);
}

class AppDimensions {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  // Margin
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 16.0;
  static const double marginL = 24.0;
  static const double marginXL = 32.0;
  
  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 50.0;
  
  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Button Heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
  
  // Avatar Sizes
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 48.0;
}

class AppShadows {
  static const BoxShadow light = BoxShadow(
    color: Color(0x1F000000),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  );
  
  static const BoxShadow medium = BoxShadow(
    color: Color(0x29000000),
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: 0,
  );
  
  static const BoxShadow heavy = BoxShadow(
    color: Color(0x33000000),
    offset: Offset(0, 8),
    blurRadius: 16,
    spreadRadius: 0,
  );
}
