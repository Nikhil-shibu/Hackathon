import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../dementia/dementia_home_screen.dart';
import '../../themes/minimalistic_theme.dart';
import 'login_screen.dart';

class ConditionSelectionScreen extends StatelessWidget {
  const ConditionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalisticTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Choose Your Profile',
          style: MinimalisticTheme.headingMedium,
        ),
        backgroundColor: MinimalisticTheme.backgroundColor,
        elevation: 1,
        centerTitle: true,
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
                'Select Your Profile',
                style: MinimalisticTheme.headingLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the profile that best fits your needs',
                style: MinimalisticTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: [
                    _buildConditionCard(
                      context,
                      'Dementia Support',
                      Icons.medical_services,
                      'Memory assistance, daily routines, and safety features',
                      Colors.blue,
                      () => _navigateToCondition(context, 'dementia'),
                    ),
                    const SizedBox(height: 20),
                    _buildConditionCard(
                      context,
                      'Autism Support',
                      Icons.favorite,
                      'Communication tools and sensory support',
                      Colors.green,
                      () => _navigateToCondition(context, 'autism'),
                    ),
                    const SizedBox(height: 20),
                    _buildConditionCard(
                      context,
                      'Down Syndrome Support',
                      Icons.accessibility,
                      'Learning assistance and communication aids',
                      Colors.orange,
                      () => _navigateToCondition(context, 'down_syndrome'),
                    ),
                    const SizedBox(height: 20),
                    _buildConditionCard(
                      context,
                      'Learning Disabilities',
                      Icons.school,
                      'Educational tools and reading assistance',
                      Colors.purple,
                      () => _navigateToCondition(context, 'learning'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    Color color,
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: MinimalisticTheme.primaryColor,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: MinimalisticTheme.headingMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: MinimalisticTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios,
                color: MinimalisticTheme.primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCondition(BuildContext context, String condition) {
    Widget destinationScreen;
    
    switch (condition) {
      case 'dementia':
        destinationScreen = const DementiaHomeScreen();
        break;
      case 'autism':
      case 'down_syndrome':
      case 'learning':
      default:
        destinationScreen = const HomeScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => destinationScreen,
      ),
    );
  }
}
