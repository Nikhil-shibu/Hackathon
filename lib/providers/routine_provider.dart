import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _routines = [];
  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic>? _currentRoutine;
  int _currentTaskIndex = 0;
  
  List<Map<String, dynamic>> get routines => _routines;
  List<Map<String, dynamic>> get tasks => _tasks;
  Map<String, dynamic>? get currentRoutine => _currentRoutine;
  int get currentTaskIndex => _currentTaskIndex;

  Future<void> initialize() async {
    await _loadDefaultRoutines();
    notifyListeners();
  }

  Future<void> _loadDefaultRoutines() async {
    // Load default routines
    _routines = [
      {
        'id': '1',
        'name': 'Morning Routine',
        'type': 'daily',
        'tasks': [
          {
            'id': '1',
            'title': 'Wake up',
            'description': 'Get out of bed and stretch',
            'duration': 5,
            'completed': false,
            'icon': '🌅',
          },
          {
            'id': '2',
            'title': 'Brush teeth',
            'description': 'Brush teeth for 2 minutes',
            'duration': 2,
            'completed': false,
            'icon': '🦷',
          },
          {
            'id': '3',
            'title': 'Get dressed',
            'description': 'Put on clothes for the day',
            'duration': 10,
            'completed': false,
            'icon': '👕',
          },
          {
            'id': '4',
            'title': 'Eat breakfast',
            'description': 'Have a healthy breakfast',
            'duration': 20,
            'completed': false,
            'icon': '🍳',
          },
        ],
        'isActive': false,
      },
      {
        'id': '2',
        'name': 'Evening Routine',
        'type': 'daily',
        'tasks': [
          {
            'id': '1',
            'title': 'Dinner',
            'description': 'Eat dinner with family',
            'duration': 30,
            'completed': false,
            'icon': '🍽️',
          },
          {
            'id': '2',
            'title': 'Brush teeth',
            'description': 'Brush teeth before bed',
            'duration': 2,
            'completed': false,
            'icon': '🦷',
          },
          {
            'id': '3',
            'title': 'Put on pajamas',
            'description': 'Change into comfortable sleepwear',
            'duration': 5,
            'completed': false,
            'icon': '🌙',
          },
          {
            'id': '4',
            'title': 'Read a book',
            'description': 'Read for 15 minutes',
            'duration': 15,
            'completed': false,
            'icon': '📚',
          },
        ],
        'isActive': false,
      },
    ];

    // Load default tasks
    _tasks = [
      {
        'id': '1',
        'title': 'Take medication',
        'description': 'Take daily medication',
        'category': 'health',
        'priority': 'high',
        'completed': false,
        'icon': '💊',
      },
      {
        'id': '2',
        'title': 'Exercise',
        'description': '30 minutes of physical activity',
        'category': 'health',
        'priority': 'medium',
        'completed': false,
        'icon': '🏃',
      },
      {
        'id': '3',
        'title': 'Call friend',
        'description': 'Check in with a friend',
        'category': 'social',
        'priority': 'low',
        'completed': false,
        'icon': '📞',
      },
    ];
  }

  Future<void> startRoutine(String routineId) async {
    final routine = _routines.firstWhere((r) => r['id'] == routineId);
    _currentRoutine = routine;
    _currentTaskIndex = 0;
    
    // Reset all tasks
    for (var task in routine['tasks']) {
      task['completed'] = false;
    }
    
    notifyListeners();
  }

  Future<void> completeCurrentTask() async {
    if (_currentRoutine != null && _currentTaskIndex < _currentRoutine!['tasks'].length) {
      _currentRoutine!['tasks'][_currentTaskIndex]['completed'] = true;
      _currentTaskIndex++;
      notifyListeners();
    }
  }

  Future<void> completeTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t['id'] == taskId);
    task['completed'] = true;
    notifyListeners();
  }

  Future<void> addRoutine(Map<String, dynamic> routine) async {
    _routines.add(routine);
    notifyListeners();
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> removeRoutine(String id) async {
    _routines.removeWhere((routine) => routine['id'] == id);
    notifyListeners();
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((task) => task['id'] == id);
    notifyListeners();
  }

  List<Map<String, dynamic>> getTasksByCategory(String category) {
    return _tasks.where((task) => task['category'] == category).toList();
  }

  List<Map<String, dynamic>> getCompletedTasks() {
    return _tasks.where((task) => task['completed'] == true).toList();
  }

  List<Map<String, dynamic>> getPendingTasks() {
    return _tasks.where((task) => task['completed'] == false).toList();
  }

  bool isRoutineComplete() {
    if (_currentRoutine == null) return false;
    return _currentTaskIndex >= _currentRoutine!['tasks'].length;
  }

  double getRoutineProgress() {
    if (_currentRoutine == null) return 0.0;
    return _currentTaskIndex / _currentRoutine!['tasks'].length;
  }
}
