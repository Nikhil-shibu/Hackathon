import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SensoryProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _sensoryTriggers = [];
  List<Map<String, dynamic>> _calmingTools = [];
  Map<String, int> _sensoryLevels = {};
  
  List<Map<String, dynamic>> get sensoryTriggers => _sensoryTriggers;
  List<Map<String, dynamic>> get calmingTools => _calmingTools;
  Map<String, int> get sensoryLevels => _sensoryLevels;

  Future<void> initialize() async {
    await _loadDefaultData();
    notifyListeners();
  }

  Future<void> _loadDefaultData() async {
    // Load default sensory triggers
    _sensoryTriggers = [
      {
        'id': '1',
        'name': 'Loud noises',
        'type': 'auditory',
        'severity': 3,
        'strategies': ['Use noise-cancelling headphones', 'Find a quiet space'],
      },
      {
        'id': '2',
        'name': 'Bright lights',
        'type': 'visual',
        'severity': 2,
        'strategies': ['Use sunglasses', 'Dim the lights', 'Avoid fluorescent lights'],
      },
      {
        'id': '3',
        'name': 'Crowded spaces',
        'type': 'environmental',
        'severity': 3,
        'strategies': ['Take breaks', 'Find a quiet corner', 'Use deep breathing'],
      },
      {
        'id': '4',
        'name': 'Unexpected touch',
        'type': 'tactile',
        'severity': 2,
        'strategies': ['Ask for permission', 'Use deep pressure', 'Communicate boundaries'],
      },
    ];

    // Load default calming tools
    _calmingTools = [
      {
        'id': '1',
        'name': 'Deep breathing',
        'type': 'breathing',
        'duration': 300, // 5 minutes
        'instructions': 'Breathe in for 4 counts, hold for 4, breathe out for 4',
        'icon': '🫁',
      },
      {
        'id': '2',
        'name': 'Progressive muscle relaxation',
        'type': 'physical',
        'duration': 600, // 10 minutes
        'instructions': 'Tense and release each muscle group',
        'icon': '💪',
      },
      {
        'id': '3',
        'name': 'Calming sounds',
        'type': 'audio',
        'duration': 0, // Variable
        'instructions': 'Listen to nature sounds or white noise',
        'icon': '🎵',
      },
      {
        'id': '4',
        'name': 'Fidget tools',
        'type': 'tactile',
        'duration': 0, // Variable
        'instructions': 'Use tactile objects to self-regulate',
        'icon': '🔄',
      },
    ];

    // Initialize sensory levels
    _sensoryLevels = {
      'auditory': 3,
      'visual': 3,
      'tactile': 3,
      'proprioceptive': 3,
      'vestibular': 3,
    };
  }

  Future<void> addTrigger(Map<String, dynamic> trigger) async {
    _sensoryTriggers.add(trigger);
    notifyListeners();
  }

  Future<void> removeTrigger(String id) async {
    _sensoryTriggers.removeWhere((trigger) => trigger['id'] == id);
    notifyListeners();
  }

  Future<void> updateSensoryLevel(String type, int level) async {
    _sensoryLevels[type] = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sensory_level_$type', level);
    notifyListeners();
  }

  Future<void> addCalmingTool(Map<String, dynamic> tool) async {
    _calmingTools.add(tool);
    notifyListeners();
  }

  Future<void> removeCalmingTool(String id) async {
    _calmingTools.removeWhere((tool) => tool['id'] == id);
    notifyListeners();
  }

  List<Map<String, dynamic>> getTriggersByType(String type) {
    return _sensoryTriggers.where((trigger) => trigger['type'] == type).toList();
  }

  List<Map<String, dynamic>> getToolsByType(String type) {
    return _calmingTools.where((tool) => tool['type'] == type).toList();
  }

  int getCurrentSensoryLoad() {
    final total = _sensoryLevels.values.reduce((a, b) => a + b);
    return total ~/ _sensoryLevels.length;
  }
}
