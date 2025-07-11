import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class EmotionScreen extends StatelessWidget {
  const EmotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Emotions'),
      ),
      body: const Center(
        child: Text(
          'Emotion Management Features Coming Soon',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
