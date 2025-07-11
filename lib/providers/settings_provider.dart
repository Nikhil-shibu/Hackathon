import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _textScale = 1.0;
  bool _hapticFeedback = true;
  bool _soundEffects = true;
  bool _highContrast = false;
  String _preferredLanguage = 'en';
  
  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;
  bool get hapticFeedback => _hapticFeedback;
  bool get soundEffects => _soundEffects;
  bool get highContrast => _highContrast;
  String get preferredLanguage => _preferredLanguage;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    _textScale = prefs.getDouble('text_scale') ?? 1.0;
    _hapticFeedback = prefs.getBool('haptic_feedback') ?? true;
    _soundEffects = prefs.getBool('sound_effects') ?? true;
    _highContrast = prefs.getBool('high_contrast') ?? false;
    _preferredLanguage = prefs.getString('preferred_language') ?? 'en';
    
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> updateTextScale(double scale) async {
    _textScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', scale);
    notifyListeners();
  }

  Future<void> updateHapticFeedback(bool enabled) async {
    _hapticFeedback = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_feedback', enabled);
    notifyListeners();
  }

  Future<void> updateSoundEffects(bool enabled) async {
    _soundEffects = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_effects', enabled);
    notifyListeners();
  }

  Future<void> updateHighContrast(bool enabled) async {
    _highContrast = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', enabled);
    notifyListeners();
  }

  Future<void> updatePreferredLanguage(String language) async {
    _preferredLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', language);
    notifyListeners();
  }
}
