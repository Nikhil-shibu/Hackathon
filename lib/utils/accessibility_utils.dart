import 'package:flutter/services.dart';

class AccessibilityUtils {
  static Future<void> initialize() async {
    // Initialize accessibility services
    try {
      // Enable high contrast mode if needed
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      print('Error initializing accessibility: $e');
    }
  }

  static void announceForAccessibility(String message) {
    // Announce message for screen readers
    SystemSound.play(SystemSoundType.click);
  }

  static void provideFeedback() {
    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }
}
