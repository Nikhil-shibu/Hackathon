import 'package:flutter/material.dart';

class MinimalisticTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF06B6D4); // Cyan
  static const Color backgroundColor = Color(0xFFF8FAFC); // Light gray
  static const Color surfaceColor = Colors.white;
  static const Color accentColor = Color(0xFF64748B); // Slate gray
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF667EEA);
  static const Color gradientEnd = Color(0xFF764BA2);
  
  // Feature Colors
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFF59E0B); // Yellow
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE0E7FF), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.25,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: textLight,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textLight,
    fontWeight: FontWeight.w500,
  );

  // Button styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  // Card styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration gradientCardDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // App Bar theme
  static AppBarTheme appBarTheme = const AppBarTheme(
    backgroundColor: surfaceColor,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: textPrimary),
    titleTextStyle: headingMedium,
    surfaceTintColor: Colors.transparent,
  );

  // Input decoration
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  // Icon themes
  static const Map<String, Color> featureColors = {
    'routine': Color(0xFF3B82F6),
    'memory': Color(0xFF10B981),
    'communication': Color(0xFFF59E0B),
    'medication': Color(0xFFEF4444),
    'safety': Color(0xFF8B5CF6),
    'cognitive': Color(0xFF06B6D4),
    'comfort': Color(0xFFEC4899),
    'caregiver': Color(0xFF6366F1),
  };

  // Helper methods
  static Color getFeatureColor(String feature) {
    return featureColors[feature] ?? primaryColor;
  }

  static BoxDecoration getFeatureCardDecoration(String feature) {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: getFeatureColor(feature).withOpacity(0.2),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: getFeatureColor(feature).withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
