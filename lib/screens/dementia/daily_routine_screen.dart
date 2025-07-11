import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  List<RoutineTask> _todaysTasks = [];
  int _selectedTaskIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadTodaysTasks();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _loadTodaysTasks() {
    // Load user's custom tasks from storage
    // Start with empty list - users will add their own tasks
    _todaysTasks = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Daily Routine',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Go back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28, color: Colors.white),
            onPressed: () => _speakTodaysSchedule(),
            tooltip: 'Read schedule aloud',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF7B68EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Today's Date and Progress
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _getCurrentDateString(),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${_getCompletedTasksCount()} of ${_todaysTasks.length} tasks completed',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _todaysTasks.isEmpty ? 0 : _getCompletedTasksCount() / _todaysTasks.length,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),

              // Next Task Alert
              if (_getNextTask() != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.alarm, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next: ${_getNextTask()!.title}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'at ${_getNextTask()!.time}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _markTaskCompleted(_getNextTask()!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.orange,
                        ),
                        child: Text('Done'),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Tasks List
              Expanded(
                child: _todaysTasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _todaysTasks.length,
                        itemBuilder: (context, index) {
                          final task = _todaysTasks[index];
                          return _buildTaskCard(task, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Task',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.blue.withOpacity(0.9),
      ),
    );
  }

  Widget _buildTaskCard(RoutineTask task, int index) {
    final isSelected = index == _selectedTaskIndex;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.isCompleted 
            ? Colors.green.withOpacity(0.2)
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? Colors.yellow
              : Colors.white.withOpacity(0.4),
          width: isSelected ? 3 : 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: task.color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            task.icon,
            size: 28,
            color: Colors.white,
          ),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: task.isCompleted 
                ? TextDecoration.lineThrough 
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text(
                  task.time,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                if (task.isRepeating)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Daily',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              task.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.volume_up,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              onPressed: () => _speakTask(task),
            ),
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) => _markTaskCompleted(task),
              activeColor: Colors.green,
              checkColor: Colors.white,
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedTaskIndex = isSelected ? -1 : index;
          });
          if (!isSelected) {
            _speakTask(task);
          }
        },
      ),
    );
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    final day = now.day;
    
    return '$weekday, $month $day';
  }

  int _getCompletedTasksCount() {
    return _todaysTasks.where((task) => task.isCompleted).length;
  }

  RoutineTask? _getNextTask() {
    // Find the next incomplete task
    if (_todaysTasks.isEmpty) return null;
    
    try {
      // First check if there are any incomplete tasks
      final incompleteTasks = _todaysTasks.where((task) => !task.isCompleted).toList();
      if (incompleteTasks.isNotEmpty) {
        return incompleteTasks.first;
      }
      
      // If all tasks are completed, return the first task
      return _todaysTasks.isNotEmpty ? _todaysTasks.first : null;
    } catch (e) {
      return null;
    }
  }

  void _markTaskCompleted(RoutineTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    
    if (task.isCompleted) {
      _speakText('Great job! You completed ${task.title}');
      _showCompletionFeedback(task);
    }
  }

  void _showCompletionFeedback(RoutineTask task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${task.title} completed! Well done!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _speakTask(RoutineTask task) async {
    final text = '${task.title} at ${task.time}. ${task.description}';
    await _speakText(text);
  }

  Future<void> _speakTodaysSchedule() async {
    if (_todaysTasks.isEmpty) {
      await _speakText('You have no tasks scheduled for today. Use the add button to create some tasks.');
      return;
    }
    
    final incompleteTasks = _todaysTasks.where((task) => !task.isCompleted).toList();
    if (incompleteTasks.isEmpty) {
      await _speakText('Great job! You have completed all your tasks for today.');
      return;
    }
    
    String schedule = 'Here are your remaining tasks for today. ';
    for (int i = 0; i < incompleteTasks.length; i++) {
      final task = incompleteTasks[i];
      schedule += '${task.title} at ${task.time}. ';
      if (i < incompleteTasks.length - 1) {
        schedule += 'Then, ';
      }
    }
    
    await _speakText(schedule);
  }

  Future<void> _speakText(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  void _showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    
    String selectedCategory = 'Medication';
    IconData selectedIcon = Icons.medical_services;
    Color selectedColor = Colors.red;
    bool isRepeating = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add New Task',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time (e.g., 8:00 AM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Medication',
                    'Meals',
                    'Exercise',
                    'Family',
                    'Rest',
                    'Entertainment',
                    'Personal Care',
                    'Other'
                  ].map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                      // Set default icon and color based on category
                      switch (selectedCategory) {
                        case 'Medication':
                          selectedIcon = Icons.medical_services;
                          selectedColor = Colors.red;
                          break;
                        case 'Meals':
                          selectedIcon = Icons.restaurant;
                          selectedColor = Colors.orange;
                          break;
                        case 'Exercise':
                          selectedIcon = Icons.directions_walk;
                          selectedColor = Colors.green;
                          break;
                        case 'Family':
                          selectedIcon = Icons.phone;
                          selectedColor = Colors.blue;
                          break;
                        case 'Rest':
                          selectedIcon = Icons.bed;
                          selectedColor = Colors.purple;
                          break;
                        case 'Entertainment':
                          selectedIcon = Icons.tv;
                          selectedColor = Colors.indigo;
                          break;
                        case 'Personal Care':
                          selectedIcon = Icons.shower;
                          selectedColor = Colors.teal;
                          break;
                        default:
                          selectedIcon = Icons.task;
                          selectedColor = Colors.grey;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isRepeating,
                      onChanged: (value) {
                        setDialogState(() {
                          isRepeating = value!;
                        });
                      },
                    ),
                    const Text('Repeat daily'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && timeController.text.isNotEmpty) {
                  final newTask = RoutineTask(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    time: timeController.text,
                    icon: selectedIcon,
                    color: selectedColor,
                    description: descriptionController.text.isEmpty 
                        ? 'Complete ${titleController.text}' 
                        : descriptionController.text,
                    isCompleted: false,
                    isRepeating: isRepeating,
                    category: selectedCategory,
                  );
                  
                  setState(() {
                    _todaysTasks.add(newTask);
                  });
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task "${titleController.text}" added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 100, color: Colors.white.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(
            'No daily tasks yet!',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first task\nusing the + button below',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Create routines for medications, meals, and more!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoutineTask {
  final String id;
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final String description;
  bool isCompleted;
  final bool isRepeating;
  final String category;

  RoutineTask({
    required this.id,
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
    required this.description,
    required this.isCompleted,
    required this.isRepeating,
    required this.category,
  });
}
