import 'package:flutter/material.dart';
import 'communication_screen.dart';
import 'auth/login_screen.dart';
import 'auth/condition_selection_screen.dart';
import '../themes/minimalistic_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalisticTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Thrive Mind',
          style: MinimalisticTheme.headingMedium,
        ),
        backgroundColor: MinimalisticTheme.backgroundColor,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: MinimalisticTheme.primaryColor,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ConditionSelectionScreen(),
              ),
            );
          },
          tooltip: 'Back to condition selection',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: MinimalisticTheme.primaryColor,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  size: 80,
                  color: MinimalisticTheme.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to Thrive Mind',
                  style: MinimalisticTheme.headingLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your supportive companion for daily life',
                  style: MinimalisticTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 400,
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      _buildFeatureCard(
                        context,
                        'Communication',
                        Icons.chat_bubble,
                        'Express yourself with pictures and words',
                        () => _navigateToFeature(context, 'Communication'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Daily Routine',
                        Icons.schedule,
                        'Organize your day with simple schedules',
                        () => _navigateToFeature(context, 'Daily Routine'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Memory Helper',
                        Icons.lightbulb,
                        'Remember important things easily',
                        () => _navigateToFeature(context, 'Memory Helper'),
                      ),
                      _buildFeatureCard(
                        context,
                        'Learning',
                        Icons.school,
                        'Practice and learn at your own pace',
                        () => _navigateToFeature(context, 'Learning'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccessibilitySettings(context),
        backgroundColor: MinimalisticTheme.primaryColor,
        tooltip: 'Accessibility settings',
        child: const Icon(Icons.accessibility, color: Colors.white),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MinimalisticTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MinimalisticTheme.accentColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: MinimalisticTheme.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: MinimalisticTheme.headingSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  description,
                  style: MinimalisticTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFeature(BuildContext context, String feature) {
    switch (feature) {
      case 'Communication':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CommunicationScreen(),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$feature feature coming soon!',
              style: const TextStyle(fontSize: 16),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
    }
  }

  void _showAccessibilitySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Accessibility Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Large Text'),
              subtitle: const Text('Make text bigger'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Voice Helper'),
              subtitle: const Text('Turn on voice guidance'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('High Contrast'),
              subtitle: const Text('Better colors for visibility'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

}
