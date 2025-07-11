import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_theme.dart';

class SensoryScreen extends StatefulWidget {
  const SensoryScreen({super.key});

  @override
  State<SensoryScreen> createState() => _SensoryScreenState();
}

class _SensoryScreenState extends State<SensoryScreen> {
  Timer? _activeTimer;
  int _remainingSeconds = 0;
  String _activeActivity = '';
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _activeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sensory Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Timer Display
            if (_isTimerRunning) ...[
              _buildActiveTimer(),
              const SizedBox(height: 24),
            ],
            
            Text(
              'Sensory Activities',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildTimers(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimers() {
    return Column(
      children: [
        _buildTimerCard('Deep Breathing', Icons.air, 4, '4-7-8 Breathing'),
        _buildTimerCard('Calming Sounds', Icons.music_note, 10, 'Nature Sounds'),
        _buildTimerCard('Grounding Exercise', Icons.self_improvement, 5, '5-4-3-2-1 Technique'),
      ],
    );
  }

  Widget _buildTimerCard(String title, IconData icon, int duration, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: TextStyle(color: AppTheme.textSecondaryColor)),
        trailing: Text('$duration min', style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold)),
        onTap: () => _startTimer(title, duration),
      ),
    );
  }

  Widget _buildActiveTimer() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    
    return Card(
      elevation: 4,
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _activeActivity,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _remainingSeconds / (_getTotalSeconds(_activeActivity)),
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _pauseTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: _stopTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer(String activity, int minutes) {
    if (_isTimerRunning) {
      _stopTimer();
    }
    
    setState(() {
      _activeActivity = activity;
      _remainingSeconds = minutes * 60;
      _isTimerRunning = true;
    });
    
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeTimer();
        }
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$activity started for $minutes minutes!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _pauseTimer() {
    if (_activeTimer != null) {
      _activeTimer!.cancel();
      _activeTimer = null;
    }
  }
  
  void _stopTimer() {
    _activeTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
      _activeActivity = '';
      _activeTimer = null;
    });
  }
  
  void _completeTimer() {
    _activeTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
      _activeTimer = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_activeActivity completed! Great job!'),
        duration: const Duration(seconds: 3),
        backgroundColor: AppTheme.successColor,
      ),
    );
    
    setState(() {
      _activeActivity = '';
    });
  }
  
  int _getTotalSeconds(String activity) {
    switch (activity) {
      case 'Deep Breathing':
        return 4 * 60;
      case 'Calming Sounds':
        return 10 * 60;
      case 'Grounding Exercise':
        return 5 * 60;
      default:
        return 5 * 60;
    }
  }
}
