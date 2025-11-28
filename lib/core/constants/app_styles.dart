import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════
  // � NATURE-INSPIRED PALETTE - Calm, Serene Travel Experience
  // ═══════════════════════════════════════════════════════════════
  
  // PRIMARY - Sage Green (Calm, Nature, Peace)
  static const Color primary = Color(0xFFB8CAB8);            // Main sage green - backgrounds
  static const Color primaryDark = Color(0xFF9DB09D);        // Deeper sage - hover states
  static const Color primaryLight = Color(0xFFC5D5C5);       // Lighter sage - subtle backgrounds
  static const Color primaryPale = Color(0xFFD8E5D8);        // Very pale sage - cards
  static const Color primaryVeryLight = Color(0xFFE8F3E8);   // Almost white mint - subtle tints
  
  // SECONDARY - Cream/Beige (Warmth, Comfort, Inviting)
  static const Color secondary = Color(0xFFF4F1E8);          // Primary cream - card backgrounds
  static const Color secondaryDark = Color(0xFFEFEAE0);      // Warm beige - deeper cards
  static const Color secondaryLight = Color(0xFFFAF8F3);     // Pale ivory - lightest cards
  static const Color secondaryPale = Color(0xFFF7F4ED);      // Light sand - subtle backgrounds
  static const Color secondaryVeryLight = Color(0xFFFAF8F5); // Almost white cream
  
  // ACCENT - Forest Green (Trust, Nature, Readability)
  static const Color accent = Color(0xFF1F2E1F);             // Dark forest green - primary text
  static const Color accentDark = Color(0xFF2C3E2C);         // Deep green - headings
  static const Color accentLight = Color(0xFF3D5A3D);        // Mid-tone green - secondary text
  static const Color accentPale = Color(0xFF4A6A4A);         // Moss green - icons
  static const Color accentVeryLight = Color(0xFF5C7C5C);    // Subtle emerald - disabled text
  
  // TERTIARY - Warm Earth Tones (Highlights, Warmth, Energy)
  static const Color tertiary = Color(0xFFFFD700);           // Sunset gold - highlights
  static const Color tertiaryDark = Color(0xFFE07856);       // Terracotta - warm accents
  static const Color tertiaryLight = Color(0xFFD4A574);      // Warm clay - subtle warmth
  static const Color tertiaryPale = Color(0xFFFBE5A0);       // Soft amber - very light
  static const Color tertiaryVeryLight = Color(0xFFFFE5D9);  // Pale peach - backgrounds
  
  // QUATERNARY - Additional Nature Tones
  static const Color quaternary = Color(0xFF8B9D83);         // Muted olive green
  static const Color quaternaryDark = Color(0xFF6B7C65);     // Deep olive
  static const Color quaternaryLight = Color(0xFFA5B59D);    // Light olive
  static const Color quaternaryPale = Color(0xFFC2CDC0);     // Very light olive
  static const Color quaternaryVeryLight = Color(0xFFDDE5DC); // Almost white olive
  
  // NEUTRAL - Warm Grays (Supporting Colors)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF5F5F0);             // Warm almost-white
  static const Color grey100 = Color(0xFFEBEBE6);
  static const Color grey200 = Color(0xFFE0E0D8);
  static const Color grey300 = Color(0xFFD0D0C8);
  static const Color grey400 = Color(0xFFB0B0A8);
  static const Color grey500 = Color(0xFF909088);            // Warm medium grey
  static const Color grey600 = Color(0xFF707068);            // Warm medium-dark grey
  static const Color grey700 = Color(0xFF505048);            // Warm dark grey
  static const Color grey800 = Color(0xFF303028);            // Warm very dark grey
  static const Color grey900 = Color(0xFF1A1A18);            // Warm almost black
  
  // Convenience aliases for neutral colors
  static const Color lightGrey = grey200;
  static const Color mediumGrey = grey500;
  static const Color darkGrey = grey700;
  static const Color slate = grey600;
  static const Color grey = grey400;
  
  // BACKGROUND COLORS - Natural, warm, inviting
  static const Color backgroundColor = Color(0xFFE9F2E9);     // Main app background (light mint green)
  static const Color cardBackground = secondary;              // Cream card background
  static const Color inputBackground = white;                 // White input fields
  static const Color surfaceLight = primaryVeryLight;         // Mint fresh for subtle surfaces
  static const Color surfaceDark = accent;                    // Forest green for dark surfaces
  static const Color surfaceElevated = secondary;             // Cream for elevated cards
  
  // TEXT COLORS - Forest greens for readability
  static const Color primaryText = accent;                    // Dark forest green
  static const Color secondaryText = accentLight;             // Mid-tone green
  static const Color hintText = grey400;                      // Warm grey
  static const Color mutedText = grey500;                     // Medium warm grey
  static const Color onPrimary = accent;                      // Dark green on sage
  static const Color onSecondary = accent;                    // Dark green on cream
  static const Color onAccent = white;                        // White on dark green
  static const Color onSurface = accent;                      // Dark green on surfaces
  
  // STATUS COLORS - Nature-inspired semantic colors
  static const Color success = Color(0xFF10B981);             // Emerald green (keep vibrant for clarity)
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  
  static const Color error = Color(0xFFDC2626);               // Muted red (less aggressive)
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFB91C1C);
  
  static const Color warning = tertiary;                      // Sunset gold
  static const Color warningLight = tertiaryLight;
  static const Color warningDark = tertiaryDark;
  
  static const Color info = Color(0xFF0891B2);                // Muted cyan (less tech-y)
  static const Color infoLight = Color(0xFF22D3EE);
  static const Color infoDark = Color(0xFF0E7490);
  
  // CHAT COLORS - Nature-inspired, calm
  static const Color userBubble = primaryLight;               // Sage green for user
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
  static const Color primaryAccent = accent;
  
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
  // 🌿 NATURAL SHADOW SYSTEM - Soft, Organic, Calm
  // ═══════════════════════════════════════════════════════════════
  
  // SOFT ELEVATION SHADOWS - Very subtle, natural depth
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x05000000),  // 2% black - barely visible
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x08000000),  // 3% black - soft shadow
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0A000000),  // 4% black
      offset: Offset(0, 3),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x0D000000),  // 5% black
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x12000000),  // 7% black
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: Color(0x1A000000),  // 10% black - strongest shadow
      offset: Offset(0, 12),
      blurRadius: 30,
      spreadRadius: 0,
    ),
  ];
  
  // CARD SHADOWS - Multi-layer for depth (like reference image)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000),  // 5% black
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),  // 2% black - subtle second layer
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x12000000),  // 7% black - lifted effect
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),  // 3% black
      offset: Offset(0, 3),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  // FLOATING SHADOWS - For elevated elements
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x0F000000),  // 6% black
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];
  
  // MODAL SHADOWS - For popups and overlays
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x1A000000),  // 10% black
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];
  
  // LEGACY ALIASES - For backward compatibility
  @Deprecated('Use sm instead')
  static const List<BoxShadow> light = sm;
  
  @Deprecated('Use md instead')
  static const List<BoxShadow> medium = md;
  
  @Deprecated('Use xl instead')
  static const List<BoxShadow> heavy = xl;
}

class AppGradients {
  // ═══════════════════════════════════════════════════════════════
  // 🌿 NATURE-INSPIRED GRADIENTS - Subtle, Organic (Minimal Use)
  // ═══════════════════════════════════════════════════════════════
  // Note: Use sparingly - prefer flat colors with photography
  
  // SUBTLE BACKGROUNDS - Very gentle gradients
  static const LinearGradient subtleSage = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primary,           // Sage green
      AppColors.primaryLight,      // Lighter sage
    ],
  );
  
  static const LinearGradient subtleCream = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.secondary,         // Cream
      AppColors.secondaryLight,    // Pale ivory
    ],
  );
  
  // IMAGE OVERLAYS - For text readability on photos
  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),          // Transparent top
      Color(0x4D000000),          // 30% black bottom
    ],
  );
  
  static const LinearGradient imageOverlayLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),          // Transparent top
      Color(0x26000000),          // 15% black bottom
    ],
  );
  
  // CARD OVERLAYS - Subtle depth on cards
  static const LinearGradient cardElevated = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.secondary,         // Cream
      AppColors.secondaryDark,     // Warm beige
    ],
  );
  
  // LEGACY - Deprecated (encourage flat colors)
  @Deprecated('Use flat colors instead - prefer nature photography for visual interest')
  static const LinearGradient primary = subtleSage;
  
  @Deprecated('Use flat colors instead')
  static const LinearGradient secondary = subtleCream;
}

// REMOVED OLD GRADIENT CLASSES - No longer needed in nature design
// - AppGradients.primary, sunset, ocean, aurora, tropical, glass, shimmer, etc.
// - Focus on flat colors + real photography instead
// Nature-inspired design uses flat colors + real photography for visual interest
