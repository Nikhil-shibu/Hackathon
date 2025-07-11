import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/condition_selection_screen.dart';
import 'safety_features_screen.dart';
import 'medication_reminders_screen.dart';
import 'daily_routine_screen.dart';
import 'memory_book_screen.dart';
import 'cognitive_stimulation_screen.dart';
import 'communication_tools_screen.dart';
import 'caregiver_portal_screen.dart';
import 'emotional_comfort_screen.dart';
import '../../themes/minimalistic_theme.dart';

class DementiaHomeScreen extends StatefulWidget {
  const DementiaHomeScreen({super.key});

  @override
  State<DementiaHomeScreen> createState() => _DementiaHomeScreenState();
}

class _DementiaHomeScreenState extends State<DementiaHomeScreen> {
  String _getUserName() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if user has a display name
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!.split(' ').first; // Get first name only
      }
      // If no display name, extract name from email
      if (user.email != null) {
        String email = user.email!;
        String nameFromEmail = email.split('@').first;
        // Capitalize first letter and make rest lowercase
        return nameFromEmail[0].toUpperCase() + nameFromEmail.substring(1).toLowerCase();
      }
    }
    return 'Friend'; // Default fallback
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: MinimalisticTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with gradient
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MinimalisticTheme.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Memory Support',
                      style: MinimalisticTheme.headingMedium,
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _triggerSOS(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: MinimalisticTheme.textSecondary,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConditionSelectionScreen(),
                              ),
                            );
                          },
                          tooltip: 'Logout',
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: MinimalisticTheme.textSecondary,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConditionSelectionScreen(),
                              ),
                            );
                          },
                          tooltip: 'Back to selection',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Welcome Message with gradient container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: MinimalisticTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: MinimalisticTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.wb_sunny_outlined,
                              size: 60,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${_getGreeting()}, ${_getUserName()}!',
                              style: MinimalisticTheme.headingLarge.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getCurrentDateString(),
                              style: MinimalisticTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Today is a good day to smile',
                              style: MinimalisticTheme.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                
                      // Main Feature Grid
                      SizedBox(
                        height: 500, // Constrained height for GridView
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.9,
                          children: [
                            _buildFeatureCard(
                              'Daily Routine',
                              Icons.calendar_today,
                              'View your schedule and tasks',
                              'routine',
                              () => _navigateToFeature(context, DailyRoutineScreen()),
                            ),
                            _buildFeatureCard(
                              'Memory Book',
                              Icons.photo_album,
                              'Photos and memories',
                              'memory',
                              () => _navigateToFeature(context, MemoryBookScreen()),
                            ),
                            _buildFeatureCard(
                              'Call Family',
                              Icons.phone,
                              'Quick contact buttons',
                              'communication',
                              () => _navigateToFeature(context, CommunicationToolsScreen()),
                            ),
                            _buildFeatureCard(
                              'Medications',
                              Icons.medical_services,
                              'Medicine reminders',
                              'medication',
                              () => _navigateToFeature(context, MedicationRemindersScreen()),
                            ),
                            _buildFeatureCard(
                              'Safety',
                              Icons.security,
                              'Location and alerts',
                              'safety',
                              () => _navigateToFeature(context, SafetyFeaturesScreen()),
                            ),
                            _buildFeatureCard(
                              'Brain Games',
                              Icons.psychology,
                              'Memory exercises',
                              'cognitive',
                              () => _navigateToFeature(context, CognitiveStimulationScreen()),
                            ),
                            _buildFeatureCard(
                              'Comfort',
                              Icons.music_note,
                              'Music and relaxation',
                              'comfort',
                              () => _navigateToFeature(context, EmotionalComfortScreen()),
                            ),
                            _buildFeatureCard(
                              'Care Team',
                              Icons.group,
                              'Caregiver portal',
                              'caregiver',
                              () => _navigateToFeature(context, CaregiverPortalScreen()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: MinimalisticTheme.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: MinimalisticTheme.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showQuickActions(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.help_outline, color: Colors.white),
          label: const Text(
            'I Need Help',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    String description,
    String featureType,
    VoidCallback onTap,
  ) {
    final featureColor = MinimalisticTheme.getFeatureColor(featureType);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: MinimalisticTheme.getFeatureCardDecoration(featureType),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: featureColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: featureColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: MinimalisticTheme.headingSmall.copyWith(
                  fontSize: 14,
                  color: MinimalisticTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: MinimalisticTheme.bodySmall.copyWith(
                  fontSize: 12,
                  color: MinimalisticTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _navigateToFeature(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _triggerSOS(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.emergency, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Emergency Alert', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sending emergency alert to your caregivers...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    // Simulate emergency alert
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency alert sent to caregivers'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How can I help you?',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton('Call Family', Icons.phone, Colors.green),
                _buildQuickActionButton('I\'m Lost', Icons.location_on, Colors.red),
                _buildQuickActionButton('Feeling Confused', Icons.help, Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String text, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // The AuthWrapper will automatically handle navigation to login screen
    } catch (e) {
      // Close loading dialog if it's still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
