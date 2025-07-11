import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernTheme {
  // Modern gradient backgrounds
  static const List<LinearGradient> modernGradients = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF667eea), // Blue
        Color(0xFF764ba2), // Purple
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2196F3), // Blue
        Color(0xFF21CBF3), // Cyan
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF4CAF50), // Green
        Color(0xFF81C784), // Light Green
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF9C27B0), // Purple
        Color(0xFFE91E63), // Pink
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF5722), // Deep Orange
        Color(0xFFFF9800), // Orange
      ],
    ),
  ];


  // Glass morphism colors
  static const glassMorphismLight = Color(0x1AFFFFFF);
  static const glassMorphismDark = Color(0x0DFFFFFF);
  static const glassMorphismBorder = Color(0x40FFFFFF);

  // Modern color palette
  static const primaryColor = Color(0xFF667eea);
  static const secondaryColor = Color(0xFF764ba2);
  static const accentColor = Color(0xFF21CBF3);
  static const successColor = Color(0xFF4CAF50);
  static const warningColor = Color(0xFFFF9800);
  static const errorColor = Color(0xFFE91E63);

  // Text styles
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        height: 1.4,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.9),
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(0.8),
        height: 1.4,
      );

  // Button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );

  // Card decorations
  static BoxDecoration get glassCardDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      );

  // App Bar style
  static AppBarTheme get appBarTheme => AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
        toolbarHeight: 80,
      );

  // Icon button styles
  static BoxDecoration get iconButtonDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      );

  static BoxDecoration get dangerIconButtonDecoration => BoxDecoration(
        color: errorColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorColor.withOpacity(0.3),
          width: 1,
        ),
      );

  // Animation durations
  static const shortDuration = Duration(milliseconds: 200);
  static const mediumDuration = Duration(milliseconds: 300);
  static const longDuration = Duration(milliseconds: 500);

  // Common spacing
  static const spacing = 16.0;
  static const spacingSmall = 8.0;
  static const spacingLarge = 24.0;
  static const spacingXLarge = 32.0;
}
