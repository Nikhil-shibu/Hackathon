import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensory_provider.dart';
import '../utils/app_theme.dart';

class SensoryDashboard extends StatelessWidget {
  const SensoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensoryProvider>(
      builder: (context, sensoryProvider, child) {
        final currentLoad = sensoryProvider.getCurrentSensoryLoad();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sensory Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: currentLoad / 5,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.getSensoryColor(currentLoad),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getSensoryStatus(currentLoad),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getSensoryColor(currentLoad),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSensoryIndicator(
                      'Sound',
                      Icons.volume_up,
                      sensoryProvider.sensoryLevels['auditory'] ?? 3,
                    ),
                    _buildSensoryIndicator(
                      'Light',
                      Icons.wb_sunny,
                      sensoryProvider.sensoryLevels['visual'] ?? 3,
                    ),
                    _buildSensoryIndicator(
                      'Touch',
                      Icons.touch_app,
                      sensoryProvider.sensoryLevels['tactile'] ?? 3,
                    ),
                    _buildSensoryIndicator(
                      'Space',
                      Icons.people,
                      sensoryProvider.sensoryLevels['proprioceptive'] ?? 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensoryIndicator(String label, IconData icon, int level) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.getSensoryColor(level),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.getSensoryColor(level),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  String _getSensoryStatus(int load) {
    if (load <= 2) return 'Calm';
    if (load <= 4) return 'Alert';
    return 'Overload';
  }
}
