import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '';
  String _userType = ''; // 'self_advocate', 'caregiver', 'parent'
  Map<String, dynamic> _spectrumProfile = {};
  
  String get userName => _userName;
  String get userType => _userType;
  Map<String, dynamic> get spectrumProfile => _spectrumProfile;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? '';
    _userType = prefs.getString('user_type') ?? '';
    
    // Load spectrum profile
    final profileKeys = prefs.getKeys().where((key) => key.startsWith('profile_'));
    for (final key in profileKeys) {
      final value = prefs.get(key);
      _spectrumProfile[key.replaceFirst('profile_', '')] = value;
    }
    
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }

  Future<void> updateUserType(String type) async {
    _userType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', type);
    notifyListeners();
  }

  Future<void> updateSpectrumProfile(Map<String, dynamic> profile) async {
    _spectrumProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    
    // Save each profile field
    for (final entry in profile.entries) {
      final key = 'profile_${entry.key}';
      final value = entry.value;
      
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    }
    
    notifyListeners();
  }
}
