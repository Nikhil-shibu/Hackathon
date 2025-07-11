import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/routine_provider.dart';
import '../utils/app_theme.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Daily Routines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRoutineDialog,
          ),
        ],
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Routine Section
                if (provider.currentRoutine != null) ...[
                  _buildCurrentRoutineCard(provider),
                  const SizedBox(height: 24),
                ],
                
                // Available Routines
                Text(
                  'Available Routines',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ...provider.routines.map((routine) => _buildRoutineCard(routine, provider)),
                
                const SizedBox(height: 24),
                
                // Quick Tasks
                Text(
                  'Quick Tasks',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildQuickTasksGrid(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentRoutineCard(RoutineProvider provider) {
    final routine = provider.currentRoutine!;
    final progress = provider.getRoutineProgress();
    final tasks = routine['tasks'] as List;
    final currentIndex = provider.currentTaskIndex;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current: ${routine['name']}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${(progress * 100).toInt()}% Complete',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            
            // Task List
            Column(
              children: tasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                final isCompleted = task['completed'];
                final isCurrent = index == currentIndex && !isCompleted;
                final isPending = index > currentIndex;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor.withOpacity(0.1)
                        : isCurrent
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.successColor
                          : isCurrent
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.successColor
                              : isCurrent
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(
                                  task['icon'],
                                  style: const TextStyle(fontSize: 20),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            if (task['description'] != null)
                              Text(
                                task['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isCurrent) ...[
                        ElevatedButton(
                          onPressed: () {
                            provider.completeCurrentTask();
                            HapticFeedback.mediumImpact();
                          },
                          child: const Text('Done'),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(Map<String, dynamic> routine, RoutineProvider provider) {
    final isActive = provider.currentRoutine?['id'] == routine['id'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : AppTheme.secondaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            isActive ? Icons.play_circle_filled : Icons.schedule,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          routine['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${routine['tasks'].length} tasks',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        trailing: isActive
            ? const Icon(Icons.play_arrow, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (!isActive) {
            provider.startRoutine(routine['id']);
            HapticFeedback.lightImpact();
          }
        },
      ),
    );
  }

  Widget _buildQuickTasksGrid(RoutineProvider provider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.tasks.length,
      itemBuilder: (context, index) {
        final task = provider.tasks[index];
        final isCompleted = task['completed'];
        
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              if (!isCompleted) {
                provider.completeTask(task['id']);
                HapticFeedback.lightImpact();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isCompleted
                    ? AppTheme.successColor.withOpacity(0.1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    task['icon'],
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddRoutineDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddRoutineDialog(),
    );
  }
}

class AddRoutineDialog extends StatefulWidget {
  const AddRoutineDialog({super.key});

  @override
  State<AddRoutineDialog> createState() => _AddRoutineDialogState();
}

class _AddRoutineDialogState extends State<AddRoutineDialog> {
  final _nameController = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];
  final _taskController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedIcon = '⭐';
  
  final List<String> _availableIcons = [
    '⭐', '🌅', '🦷', '👕', '🍳', '🧘', '📚', '🚿', '🎵', '🏃', '💊', '🛌'
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Create New Routine',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Routine name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Routine Name',
                hintText: 'e.g., Morning Routine',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tasks section
            Row(
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddTaskDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Tasks list
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks added yet.\nTap "Add Task" to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Text(
                              task['icon'],
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(task['title']),
                            subtitle: Text(
                              '${task['duration']} minutes - ${task['description']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _tasks.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveRoutine,
                    child: const Text('Save Routine'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'e.g., Brush teeth',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Brush for 2 minutes',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'e.g., 5',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Choose an icon:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableIcons.map((icon) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : null,
                        border: Border.all(
                          color: _selectedIcon == icon
                              ? AppTheme.primaryColor
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _taskController.clear();
              _descriptionController.clear();
              _durationController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
  
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': _taskController.text,
          'description': _descriptionController.text,
          'duration': int.tryParse(_durationController.text) ?? 5,
          'icon': _selectedIcon,
          'completed': false,
        });
      });
      _taskController.clear();
      _descriptionController.clear();
      _durationController.clear();
      Navigator.pop(context);
    }
  }
  
  void _saveRoutine() {
    final routine = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nameController.text,
      'type': 'custom',
      'tasks': _tasks,
      'isActive': false,
    };
    
    context.read<RoutineProvider>().addRoutine(routine);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Routine "${_nameController.text}" created successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _taskController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
