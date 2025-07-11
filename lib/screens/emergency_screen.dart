import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Emergency Help'),
        backgroundColor: AppTheme.errorColor,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final profile = userProvider.spectrumProfile;
          final caregiverName = profile['caregiver_name'] ?? '';
          final caregiverPhone = profile['caregiver_phone'] ?? '';
          final emergencyName = profile['emergency_contact'] ?? '';
          final emergencyPhone = profile['emergency_phone'] ?? '';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Emergency header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emergency,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Emergency Help',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Get help when you need it most',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Quick emergency actions
                Text(
                  'Quick Emergency Actions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                // Emergency services
                _buildEmergencyCard(
                  'Call 911',
                  'Emergency Services',
                  Icons.local_hospital,
                  AppTheme.errorColor,
                  () => _makeCall('911'),
                ),
                
                if (caregiverName.isNotEmpty && caregiverPhone.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildEmergencyCard(
                    'Call $caregiverName',
                    'Caregiver: $caregiverPhone',
                    Icons.person,
                    AppTheme.primaryColor,
                    () => _makeCall(caregiverPhone),
                  ),
                ],
                
                if (emergencyName.isNotEmpty && emergencyPhone.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildEmergencyCard(
                    'Call $emergencyName',
                    'Emergency Contact: $emergencyPhone',
                    Icons.contact_emergency,
                    AppTheme.warningColor,
                    () => _makeCall(emergencyPhone),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Quick communication
                Text(
                  'Quick Communication',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendQuickMessage('I need help'),
                        icon: const Icon(Icons.message),
                        label: const Text('Send "I need help"'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendQuickMessage('I am overwhelmed'),
                        icon: const Icon(Icons.psychology),
                        label: const Text('Send "I am overwhelmed"'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmergencyCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.phone,
                color: color,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      // Handle error - show snackbar or dialog
      print('Could not launch $launchUri');
    }
  }
  
  void _sendQuickMessage(String message) {
    // In a real app, this would send SMS or use other messaging
    print('Sending message: $message');
    // For now, just show a snackbar
  }
}
