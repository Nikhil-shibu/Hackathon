import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import 'main_dashboard.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Form data
  String _name = '';
  String _userType = '';
  String _communicationStyle = '';
  List<String> _sensoryTriggers = [];
  List<String> _supportNeeds = [];
  List<String> _interests = [];
  bool _verbal = true;
  bool _needsVisualSupport = false;
  bool _needsRoutineSupport = false;
  bool _needsSensorySupport = false;
  
  // Caregiver and emergency info
  String _caregiverName = '';
  String _caregiverPhone = '';
  String _emergencyContact = '';
  String _emergencyPhone = '';
  bool _caregiverPhoneValid = true;
  bool _emergencyPhoneValid = true;

  final List<String> _userTypes = [
    'self_advocate',
    'caregiver',
    'parent',
    'support_worker',
  ];

  final List<String> _communicationStyles = [
    'verbal',
    'visual',
    'written',
    'mixed',
  ];

  final List<String> _commonTriggers = [
    'Loud noises',
    'Bright lights',
    'Crowded spaces',
    'Unexpected touch',
    'Strong smells',
    'Busy patterns',
    'Sudden changes',
    'Multiple conversations',
  ];

  final List<String> _supportOptions = [
    'Communication aids',
    'Sensory tools',
    'Routine support',
    'Social stories',
    'Emotion regulation',
    'Transition support',
    'Emergency communication',
    'Calming techniques',
  ];

  final List<String> _commonInterests = [
    'Animals',
    'Technology',
    'Art & Drawing',
    'Music',
    'Reading',
    'Science',
    'Sports',
    'Gaming',
    'Nature',
    'Cooking',
    'Mathematics',
    'History',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Profile Setup',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _completeSetup(),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 7,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildNamePage(),
                  _buildCommunicationPage(),
                  _buildSensoryPage(),
                  _buildSupportPage(),
                  _buildInterestsPage(),
                  _buildCaregiverPage(),
                  _buildEmergencyPage(),
                ],
              ),
            ),
            // Navigation
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 6) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
                        _completeSetup();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _currentPage < 6 ? 'Next' : 'Complete',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'This helps us personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (value) => _name = value,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserTypePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Text(
            'How will you be using this app?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...{
            'self_advocate': {
              'title': 'For myself',
              'description': 'I am an autistic individual using this app',
              'icon': Icons.person,
            },
            'caregiver': {
              'title': 'As a caregiver',
              'description': 'I am helping someone else use this app',
              'icon': Icons.favorite,
            },
            'parent': {
              'title': 'As a parent',
              'description': 'I am setting this up for my child',
              'icon': Icons.family_restroom,
            },
            'support_worker': {
              'title': 'As a support worker',
              'description': 'I provide professional support',
              'icon': Icons.work,
            },
          }.entries.map((entry) {
            final isSelected = _userType == entry.key;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _userType = entry.key;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          entry.value['icon'] as IconData,
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value['title'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.value['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? AppTheme.primaryColor : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
        ),
      ),
    );
  }

  Widget _buildCommunicationPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Text(
            'How do you prefer to communicate?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...{
            'verbal': {
              'title': 'Speaking',
              'description': 'I primarily communicate by speaking',
              'icon': '🗣️',
            },
            'visual': {
              'title': 'Visual aids',
              'description': 'I use pictures, symbols, or cards',
              'icon': '🖼️',
            },
            'written': {
              'title': 'Writing/Typing',
              'description': 'I prefer to write or type',
              'icon': '✍️',
            },
            'mixed': {
              'title': 'Mixed methods',
              'description': 'I use different ways depending on the situation',
              'icon': '🔄',
            },
          }.entries.map((entry) {
            final isSelected = _communicationStyle == entry.key;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _communicationStyle = entry.key;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          entry.value['icon'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value['title'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.value['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? AppTheme.primaryColor : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
        ),
      ),
    );
  }

  Widget _buildSensoryPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'What sensory experiences are challenging for you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Select all that apply',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _commonTriggers.length,
              itemBuilder: (context, index) {
                final trigger = _commonTriggers[index];
                final isSelected = _sensoryTriggers.contains(trigger);
                return Material(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _sensoryTriggers.remove(trigger);
                        } else {
                          _sensoryTriggers.add(trigger);
                        }
                      });
                    },
                    child: Center(
                      child: Text(
                        trigger,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'What types of support would be most helpful?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Select all that apply',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: _supportOptions.length,
              itemBuilder: (context, index) {
                final option = _supportOptions[index];
                final isSelected = _supportNeeds.contains(option);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _supportNeeds.remove(option);
                          } else {
                            _supportNeeds.add(option);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                              color: isSelected ? AppTheme.primaryColor : Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text(
            'What are your interests?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'This helps us personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _commonInterests.length,
              itemBuilder: (context, index) {
                final interest = _commonInterests[index];
                final isSelected = _interests.contains(interest);
                return Material(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _interests.remove(interest);
                        } else {
                          _interests.add(interest);
                        }
                      });
                    },
                    child: Center(
                      child: Text(
                        interest,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSetup() async {
    // Save profile data
    final userProvider = context.read<UserProvider>();
    await userProvider.updateUserName(_name);
    await userProvider.updateUserType('self_advocate'); // Default to self advocate
    
    final profile = {
      'communication_style': _communicationStyle,
      'sensory_triggers': _sensoryTriggers,
      'support_needs': _supportNeeds,
      'interests': _interests,
      'verbal': _verbal,
      'needs_visual_support': _needsVisualSupport,
      'needs_routine_support': _needsRoutineSupport,
      'needs_sensory_support': _needsSensorySupport,
      'caregiver_name': _caregiverName,
      'caregiver_phone': _caregiverPhone,
      'emergency_contact': _emergencyContact,
      'emergency_phone': _emergencyPhone,
    };
    
    await userProvider.updateSpectrumProfile(profile);
    
    // Mark setup as complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_setup', true);
    
    // Navigate to main dashboard
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainDashboard(),
        ),
      );
    };
  }

  Widget _buildCaregiverPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Caregiver Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Who can we contact to help you?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) => _caregiverName = value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: 'Caregiver name',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _caregiverPhone = value;
                  _caregiverPhoneValid = value.isEmpty || _isValidPhoneNumber(value);
                });
              },
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Caregiver phone number',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
                errorText: !_caregiverPhoneValid 
                    ? 'Please enter a valid phone number (10-15 digits)' 
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Check if it's a valid length (10-15 digits)
    return digits.length >= 10 && digits.length <= 15;
  }

  Widget _buildEmergencyPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Who should we call in an emergency?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) => _emergencyContact = value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: 'Emergency contact name',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _emergencyPhone = value;
                  _emergencyPhoneValid = value.isEmpty || _isValidPhoneNumber(value);
                });
              },
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Emergency phone number',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
                errorText: !_emergencyPhoneValid 
                    ? 'Please enter a valid phone number (10-15 digits)' 
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
