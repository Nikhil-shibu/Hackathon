import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/sensory_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/communication_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/emotion_tracker.dart';
import '../widgets/sensory_dashboard.dart';
import '../widgets/routine_progress.dart';
import '../screens/communication_screen.dart';
import '../screens/routine_screen.dart';
import '../screens/sensory_screen.dart';
import '../screens/emotion_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/settings_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${userProvider.userName.isNotEmpty ? userProvider.userName : 'Friend'}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => _showNotifications(context),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _navigateToSettings(context),
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              _buildHomePage(),
              const CommunicationScreen(),
              const RoutineScreen(),
              const SensoryScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondaryColor,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Communicate',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Routines',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.spa),
                label: 'Sensory',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToEmergency(context),
            backgroundColor: AppTheme.errorColor,
            child: const Icon(Icons.emergency, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 24),
            
            // Sensory Dashboard
            const SensoryDashboard(),
            const SizedBox(height: 24),
            
            // Routine Progress
            const RoutineProgress(),
            const SizedBox(height: 24),
            
            // Recent Activities
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        QuickActionCard(
          title: 'I Need Help',
          icon: Icons.help_outline,
          color: AppTheme.errorColor,
          onTap: () => _navigateToEmergency(context),
        ),
        QuickActionCard(
          title: 'Feeling Overwhelmed',
          icon: Icons.psychology,
          color: AppTheme.warningColor,
          onTap: () => _showCalmingTools(context),
        ),
        QuickActionCard(
          title: 'Start Routine',
          icon: Icons.play_arrow,
          color: AppTheme.primaryColor,
          onTap: () => _startQuickRoutine(context),
        ),
        QuickActionCard(
          title: 'Communicate',
          icon: Icons.chat,
          color: AppTheme.secondaryColor,
          onTap: () => _navigateToCommunication(context),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'Completed Morning Routine',
              '2 hours ago',
              Icons.check_circle,
              AppTheme.successColor,
            ),
            _buildActivityItem(
              'Used Calming Tool',
              '3 hours ago',
              Icons.spa,
              AppTheme.calmColor,
            ),
            _buildActivityItem(
              'Emotion Check-in',
              '5 hours ago',
              Icons.mood,
              AppTheme.focusColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToEmergency(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyScreen()),
    );
  }

  void _showCalmingTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Calming Tools',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.air),
              title: const Text('Deep Breathing'),
              subtitle: const Text('4-7-8 breathing technique'),
              onTap: () => _startBreathingExercise(context),
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Calming Sounds'),
              subtitle: const Text('Nature sounds and white noise'),
              onTap: () => _startCalmingSounds(context),
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement),
              title: const Text('Grounding Exercise'),
              subtitle: const Text('5-4-3-2-1 technique'),
              onTap: () => _startGroundingExercise(context),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuickRoutine(BuildContext context) {
    final routineProvider = context.read<RoutineProvider>();
    if (routineProvider.routines.isNotEmpty) {
      routineProvider.startRoutine(routineProvider.routines.first['id']);
      setState(() {
        _currentIndex = 2;
        _pageController.animateToPage(
          2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _navigateToCommunication(BuildContext context) {
    setState(() {
      _currentIndex = 1;
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startBreathingExercise(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deep Breathing'),
        content: const Text('Breathe in for 4 counts, hold for 7, breathe out for 8. Repeat 3-4 times.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _startCalmingSounds(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playing calming sounds...'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startGroundingExercise(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grounding Exercise'),
        content: const Text('Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
