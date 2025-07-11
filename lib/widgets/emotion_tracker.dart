import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/communication_provider.dart';
import '../utils/app_theme.dart';

class EmotionTracker extends StatelessWidget {
  const EmotionTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Emotion',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: Provider.of<CommunicationProvider>(context)
                  .emotionCards
                  .map((emotion) => _buildEmotionIcon(
                      emotion['emotion'], emotion['symbol']))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionIcon(String emotion, String symbol) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.getEmotionColor(emotion),
          child: Text(
            symbol,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          emotion,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
