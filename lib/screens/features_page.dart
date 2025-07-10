import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/feature_card.dart';
import '../models/feature.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      Feature(
        icon: '🗣',
        title: 'Voice Commands',
        description: 'Schedule tasks, call caregiver, get weather',
        color: const Color(0xFF6750A4),
        onTap: () => _handleFeatureTap(context, 'Voice Commands'),
      ),
      Feature(
        icon: '🧠',
        title: 'Smart Reminders',
        description: 'Take medicine, attend class, hydration',
        color: const Color(0xFF4CAF50),
        onTap: () => _handleFeatureTap(context, 'Smart Reminders'),
      ),
      Feature(
        icon: '🧑‍🦽',
        title: 'Accessibility Modes',
        description: 'Voice-only, gesture-based, switch control',
        color: const Color(0xFFFF9800),
        onTap: () => _handleFeatureTap(context, 'Accessibility Modes'),
      ),
      Feature(
        icon: '🩺',
        title: 'Health Logs',
        description: 'Mood tracking, pain scale, vitals',
        color: const Color(0xFFE91E63),
        onTap: () => _handleFeatureTap(context, 'Health Logs'),
      ),
      Feature(
        icon: '🆘',
        title: 'SOS Mode',
        description: 'Emergency call + location sharing',
        color: const Color(0xFFF44336),
        onTap: () => _handleFeatureTap(context, 'SOS Mode'),
      ),
      Feature(
        icon: '📚',
        title: 'Learning Aid',
        description: 'Explain concepts in user-friendly ways',
        color: const Color(0xFF2196F3),
        onTap: () => _handleFeatureTap(context, 'Learning Aid'),
      ),
      Feature(
        icon: '🧘',
        title: 'Calm Mode',
        description: 'Play soothing music or guide breathing exercises',
        color: const Color(0xFF9C27B0),
        onTap: () => _handleFeatureTap(context, 'Calm Mode'),
      ),
      Feature(
        icon: '🔄',
        title: 'Offline Capability',
        description: 'Basic features without Internet',
        color: const Color(0xFF607D8B),
        onTap: () => _handleFeatureTap(context, 'Offline Capability'),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Accessibility Features',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6750A4),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to your accessibility companion',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a feature to get started',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    return FeatureCard(feature: features[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFeatureTap(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature coming soon!'),
        backgroundColor: const Color(0xFF6750A4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 