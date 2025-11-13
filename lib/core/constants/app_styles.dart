import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════
  // 🎨 MODERN SOPHISTICATED PALETTE - Premium Travel Experience
  // ═══════════════════════════════════════════════════════════════
  
  // PRIMARY - Deep Indigo/Royal Purple (Trust, Sophistication, Premium)
  static const Color primary = Color(0xFF4F46E5);            // Indigo-600: Main brand color
  static const Color primaryDark = Color(0xFF4338CA);        // Indigo-700: Darker variant
  static const Color primaryLight = Color(0xFF6366F1);       // Indigo-500: Lighter variant
  static const Color primaryPale = Color(0xFF818CF8);        // Indigo-400: Very light
  static const Color primaryVeryLight = Color(0xFFE0E7FF);   // Indigo-100: Subtle backgrounds
  
  // SECONDARY - Electric Blue/Cyan (Innovation, Technology, Clarity)
  static const Color secondary = Color(0xFF06B6D4);          // Cyan-500: Secondary actions
  static const Color secondaryDark = Color(0xFF0891B2);      // Cyan-600: Darker variant
  static const Color secondaryLight = Color(0xFF22D3EE);     // Cyan-400: Lighter variant
  static const Color secondaryPale = Color(0xFF67E8F9);      // Cyan-300: Very light
  static const Color secondaryVeryLight = Color(0xFFCFFAFE); // Cyan-100: Subtle backgrounds
  
  // ACCENT - Vibrant Coral/Rose (Energy, Action, Warmth)
  static const Color accent = Color(0xFFFF5A5F);             // Vibrant coral-red
  static const Color accentDark = Color(0xFFE14950);         // Darker coral
  static const Color accentLight = Color(0xFFFF7B7F);        // Lighter coral
  static const Color accentPale = Color(0xFFFFA5A8);         // Very light coral
  static const Color accentVeryLight = Color(0xFFFFE8E9);    // Subtle coral background
  
  // TERTIARY - Emerald Green (Success, Growth, Nature)
  static const Color tertiary = Color(0xFF10B981);           // Emerald-500: Success & nature
  static const Color tertiaryDark = Color(0xFF059669);       // Emerald-600: Darker variant
  static const Color tertiaryLight = Color(0xFF34D399);      // Emerald-400: Lighter variant
  static const Color tertiaryPale = Color(0xFF6EE7B7);       // Emerald-300: Very light
  static const Color tertiaryVeryLight = Color(0xFFD1FAE5);  // Emerald-100: Subtle backgrounds
  
  // QUATERNARY - Amber/Gold (Premium, Luxury, Warmth)
  static const Color quaternary = Color(0xFFF59E0B);         // Amber-500: Premium feel
  static const Color quaternaryDark = Color(0xFFD97706);     // Amber-600: Darker variant
  static const Color quaternaryLight = Color(0xFFFBBF24);    // Amber-400: Lighter variant
  static const Color quaternaryPale = Color(0xFFFCD34D);     // Amber-300: Very light
  static const Color quaternaryVeryLight = Color(0xFFFEF3C7); // Amber-100: Subtle backgrounds
  
  // NEUTRAL - Modern grays with blue undertones
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);             // Lightest
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);            // Darkest
  
  // Convenience aliases for neutral colors
  static const Color lightGrey = grey100;
  static const Color mediumGrey = grey500;
  static const Color darkGrey = grey700;
  static const Color slate = grey600;
  static const Color grey = grey400;
  
  // BACKGROUND COLORS - Clean, modern, with subtle tints
  static const Color backgroundColor = Color(0xFFFAFBFC);    // Subtle blue-grey tint
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8FAFC);    // Light slate tint
  static const Color surfaceLight = grey50;
  static const Color surfaceDark = grey900;
  static const Color surfaceElevated = Color(0xFFFFFFFF);    // Cards, modals
  
  // TEXT COLORS - Optimized for readability
  static const Color primaryText = grey900;
  static const Color secondaryText = grey600;
  static const Color hintText = grey400;
  static const Color mutedText = grey500;
  static const Color onPrimary = white;                      // Text on primary color
  static const Color onSecondary = white;                    // Text on secondary color
  static const Color onAccent = white;                       // Text on accent color
  static const Color onSurface = grey900;                    // Text on surface
  
  // STATUS COLORS - Clear semantic meaning
  static const Color success = tertiary;                     // Emerald green
  static const Color successLight = tertiaryLight;
  static const Color successDark = tertiaryDark;
  
  static const Color error = Color(0xFFEF4444);              // Red-500
  static const Color errorLight = Color(0xFFF87171);         // Red-400
  static const Color errorDark = Color(0xFFDC2626);          // Red-600
  
  static const Color warning = quaternary;                   // Amber
  static const Color warningLight = quaternaryLight;
  static const Color warningDark = quaternaryDark;
  
  static const Color info = secondary;                       // Cyan/Blue
  static const Color infoLight = secondaryLight;
  static const Color infoDark = secondaryDark;
  
  // CHAT COLORS - Modern and inviting
  static const Color userBubble = primary;                   // Indigo gradient
  static const Color userBubbleLight = primaryLight;
  static const Color aiBubble = white;
  static const Color aiBubbleBorder = grey200;
  static const Color chatBackground = grey50;
  
  // SHADOW COLORS - Sophisticated depth
  static const Color shadowLight = Color(0x0A000000);        // 4% opacity
  static const Color shadowMedium = Color(0x14000000);       // 8% opacity
  static const Color shadowHeavy = Color(0x1F000000);        // 12% opacity
  static const Color shadowPrimary = Color(0x264F46E5);      // Primary with opacity
  static const Color shadowAccent = Color(0x26FF5A5F);       // Accent with opacity
  
  // GRADIENT COLORS - For stunning visual effects
  static const Color gradientPrimaryStart = primary;
  static const Color gradientPrimaryMid = Color(0xFF5B52EA);
  static const Color gradientPrimaryEnd = primaryPale;
  
  static const Color gradientSecondaryStart = secondary;
  static const Color gradientSecondaryMid = Color(0xFF14C2DD);
  static const Color gradientSecondaryEnd = secondaryPale;
  
  static const Color gradientAccentStart = accent;
  static const Color gradientAccentMid = Color(0xFFFF6F73);
  static const Color gradientAccentEnd = accentPale;
  
  // SPECIAL EFFECTS - Glassmorphism, overlays, etc.
  static const Color glassBackground = Color(0xCCFFFFFF);    // 80% opacity white
  static const Color glassBorder = Color(0x33FFFFFF);        // 20% opacity white
  static const Color overlayLight = Color(0x33000000);       // 20% opacity black
  static const Color overlayDark = Color(0x66000000);        // 40% opacity black
  static const Color scrim = Color(0x99000000);              // 60% opacity black
  
  // LEGACY COMPATIBILITY - Deprecated but maintained for backwards compatibility
  @Deprecated('Use primary instead')
  static const Color primaryGreen = primary;
  
  @Deprecated('Use primaryLight instead')
  static const Color lightGreen = primaryLight;
  
  @Deprecated('Use accent instead')
  static const Color accentGreen = accent;
  
  @Deprecated('Use quaternary instead')
  static const Color orange = quaternary;
  
  @Deprecated('Use onPrimary instead')
  static const Color onOrange = onPrimary;
  
  @Deprecated('Use accent instead')
  static const Color coral = accent;
  
  @Deprecated('Use accentPale instead')
  static const Color peach = accentPale;
  
  @Deprecated('Use quaternary instead')
  static const Color tangerine = quaternary;
  
  @Deprecated('Use accentDark instead')
  static const Color sunset = accentDark;
  
  @Deprecated('Use shadowPrimary instead')
  static const Color shadowOrange = shadowPrimary;
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
  // ═══════════════════════════════════════════════════════════════
  // 💫 MODERN SHADOW SYSTEM - Depth & Elegance
  // ═══════════════════════════════════════════════════════════════
  
  // STANDARD ELEVATION SHADOWS - Following Material Design 3 principles
  static const BoxShadow xs = BoxShadow(
    color: AppColors.shadowLight,
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
  );
  
  static const BoxShadow sm = BoxShadow(
    color: AppColors.shadowLight,
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );
  
  static const BoxShadow md = BoxShadow(
    color: AppColors.shadowMedium,
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: -1,
  );
  
  static const BoxShadow lg = BoxShadow(
    color: AppColors.shadowMedium,
    offset: Offset(0, 8),
    blurRadius: 16,
    spreadRadius: -2,
  );
  
  static const BoxShadow xl = BoxShadow(
    color: AppColors.shadowHeavy,
    offset: Offset(0, 12),
    blurRadius: 24,
    spreadRadius: -4,
  );
  
  static const BoxShadow xxl = BoxShadow(
    color: AppColors.shadowHeavy,
    offset: Offset(0, 20),
    blurRadius: 40,
    spreadRadius: -8,
  );
  
  // COLORED GLOW SHADOWS - For visual impact 
  static const BoxShadow primaryGlow = BoxShadow(
    color: AppColors.shadowPrimary,
    offset: Offset(0, 4),
    blurRadius: 20,
    spreadRadius: 0,
  );
  
  static const BoxShadow primaryGlowStrong = BoxShadow(
    color: Color(0x404F46E5),  // Primary with 25% opacity
    offset: Offset(0, 8),
    blurRadius: 32,
    spreadRadius: 0,
  );
  
  static const BoxShadow secondaryGlow = BoxShadow(
    color: Color(0x2606B6D4),  // Secondary with 15% opacity
    offset: Offset(0, 4),
    blurRadius: 20,
    spreadRadius: 0,
  );
  
  static const BoxShadow accentGlow = BoxShadow(
    color: AppColors.shadowAccent,
    offset: Offset(0, 4),
    blurRadius: 20,
    spreadRadius: 0,
  );
  
  static const BoxShadow accentGlowStrong = BoxShadow(
    color: Color(0x40FF5A5F),  // Accent with 25% opacity
    offset: Offset(0, 8),
    blurRadius: 32,
    spreadRadius: 0,
  );
  
  // INNER SHADOWS - For depth and pressed states
  static const BoxShadow innerSm = BoxShadow(
    color: AppColors.shadowLight,
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: -1,
  );
  
  static const BoxShadow innerMd = BoxShadow(
    color: AppColors.shadowMedium,
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: -2,
  );
  
  // MULTI-LAYER SHADOWS - For realistic depth (use in List)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];
  
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: AppColors.shadowHeavy,
      offset: Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];
  
  // LEGACY SHADOWS - Deprecated but maintained
  @Deprecated('Use sm instead')
  static const BoxShadow light = sm;
  
  @Deprecated('Use md instead')
  static const BoxShadow medium = md;
  
  @Deprecated('Use xl instead')
  static const BoxShadow heavy = xl;
  
  @Deprecated('Use primaryGlow instead')
  static const BoxShadow orangeGlow = primaryGlow;
  
  @Deprecated('Use primaryGlowStrong instead')
  static const BoxShadow orangeGlowStrong = primaryGlowStrong;
  
  @Deprecated('Use primaryGlow instead')
  static const BoxShadow softOrange = primaryGlow;
}

class AppGradients {
  // ═══════════════════════════════════════════════════════════════
  // 🌈 MODERN GRADIENT SYSTEM - Sophisticated & Eye-catching
  // ═══════════════════════════════════════════════════════════════
  
  // PRIMARY GRADIENTS - Indigo/Purple magic ✨
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.gradientPrimaryStart, AppColors.gradientPrimaryMid, AppColors.gradientPrimaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryVertical = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient primaryHorizontal = LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // SECONDARY GRADIENTS - Electric Blue/Cyan energy ⚡
  static const LinearGradient secondary = LinearGradient(
    colors: [AppColors.gradientSecondaryStart, AppColors.gradientSecondaryMid, AppColors.gradientSecondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryVertical = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ACCENT GRADIENTS - Vibrant Coral/Rose warmth 🌸
  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.gradientAccentStart, AppColors.gradientAccentMid, AppColors.gradientAccentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentVertical = LinearGradient(
    colors: [AppColors.accent, AppColors.accentDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // SUCCESS GRADIENTS - Emerald green vitality 🌿
  static const LinearGradient success = LinearGradient(
    colors: [AppColors.tertiaryLight, AppColors.tertiary, AppColors.tertiaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // MULTI-COLOR GRADIENTS - Stunning combinations 🎨
  static const LinearGradient sunset = LinearGradient(
    colors: [AppColors.accent, AppColors.quaternary, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient ocean = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient aurora = LinearGradient(
    colors: [AppColors.primaryLight, AppColors.secondaryLight, AppColors.tertiaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient tropical = LinearGradient(
    colors: [AppColors.secondary, AppColors.tertiary, AppColors.quaternary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // SUBTLE BACKGROUND GRADIENTS - For cards and surfaces
  static const LinearGradient subtleGrey = LinearGradient(
    colors: [AppColors.grey50, AppColors.grey100],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient subtlePrimary = LinearGradient(
    colors: [AppColors.white, AppColors.primaryVeryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient subtleSecondary = LinearGradient(
    colors: [AppColors.white, AppColors.secondaryVeryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardElevated = LinearGradient(
    colors: [AppColors.white, Color(0xFFFAFBFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // GLASSMORPHISM GRADIENTS - Modern frosted glass effect
  static const LinearGradient glass = LinearGradient(
    colors: [AppColors.glassBackground, Color(0xB3FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassPrimary = LinearGradient(
    colors: [Color(0xCC4F46E5), Color(0xB34F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // OVERLAY GRADIENTS - For image overlays and scrims
  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Color(0x00000000), AppColors.overlayDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient lightOverlay = LinearGradient(
    colors: [Color(0x00FFFFFF), Color(0xCCFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient scrimBottom = LinearGradient(
    colors: [Color(0x00000000), AppColors.scrim],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient scrimTop = LinearGradient(
    colors: [AppColors.scrim, Color(0x00000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // RADIAL GRADIENTS - For special effects and hero sections
  static const RadialGradient primaryRadial = RadialGradient(
    colors: [AppColors.primaryPale, AppColors.primary, AppColors.primaryDark],
    center: Alignment.center,
    radius: 1.2,
  );
  
  static const RadialGradient secondaryRadial = RadialGradient(
    colors: [AppColors.secondaryPale, AppColors.secondary, AppColors.secondaryDark],
    center: Alignment.center,
    radius: 1.2,
  );
  
  static const RadialGradient accentRadial = RadialGradient(
    colors: [AppColors.accentPale, AppColors.accent, AppColors.accentDark],
    center: Alignment.center,
    radius: 1.2,
  );
  
  // SHIMMER GRADIENT - For loading animations
  static const LinearGradient shimmer = LinearGradient(
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFE0E0E0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );
  
  // LEGACY GRADIENTS - Deprecated but maintained for backwards compatibility
  @Deprecated('Use primary instead')
  static const LinearGradient primaryOrange = primary;
  
  @Deprecated('Use accent instead')
  static const LinearGradient deepOrange = accent;
  
  @Deprecated('Use sunset instead')
  static const LinearGradient warmGlow = sunset;
  
  @Deprecated('Use ocean instead')
  static const LinearGradient orangeTeal = ocean;
  
  @Deprecated('Use aurora instead')
  static const LinearGradient orangePurple = aurora;
  
  @Deprecated('Use subtleGrey instead')
  static const LinearGradient lightWarm = subtleGrey;
  
  @Deprecated('Use cardElevated instead')
  static const LinearGradient cardGradient = cardElevated;
  
  @Deprecated('Use primaryRadial instead')
  static const RadialGradient orangeRadial = primaryRadial;
}
