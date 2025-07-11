import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<SettingsProvider, UserProvider>(
        builder: (context, settingsProvider, userProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                _buildSectionHeader('Profile'),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        userProvider.userName.isNotEmpty
                            ? userProvider.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(userProvider.userName.isNotEmpty
                        ? userProvider.userName
                        : 'User'),
                    subtitle: const Text('Edit profile information'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showEditProfileDialog(userProvider),
                  ),
                ),
                const SizedBox(height: 24),

                // Appearance Section
                _buildSectionHeader('Appearance'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: settingsProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            settingsProvider.updateThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.text_fields),
                        title: const Text('Text Size'),
                        subtitle: Text('${(settingsProvider.textScale * 100).toInt()}%'),
                        trailing: SizedBox(
                          width: 150,
                          child: Slider(
                            value: settingsProvider.textScale,
                            min: 0.8,
                            max: 2.0,
                            divisions: 6,
                            onChanged: (value) {
                              settingsProvider.updateTextScale(value);
                            },
                          ),
                        ),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.contrast),
                        title: const Text('High Contrast'),
                        subtitle: const Text('Easier to see interface'),
                        value: settingsProvider.highContrast,
                        onChanged: (value) {
                          settingsProvider.updateHighContrast(value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Interaction Section
                _buildSectionHeader('Interaction'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.vibration),
                        title: const Text('Haptic Feedback'),
                        subtitle: const Text('Feel vibrations when tapping'),
                        value: settingsProvider.hapticFeedback,
                        onChanged: (value) {
                          settingsProvider.updateHapticFeedback(value);
                        },
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.volume_up),
                        title: const Text('Sound Effects'),
                        subtitle: const Text('Play sounds for actions'),
                        value: settingsProvider.soundEffects,
                        onChanged: (value) {
                          settingsProvider.updateSoundEffects(value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Emergency Contacts
                _buildSectionHeader('Emergency Contacts'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Caregiver'),
                        subtitle: Text(
                          userProvider.spectrumProfile['caregiver_name']?.isNotEmpty == true
                              ? userProvider.spectrumProfile['caregiver_name']
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showEditContactDialog('caregiver', userProvider),
                      ),
                      ListTile(
                        leading: const Icon(Icons.contact_emergency),
                        title: const Text('Emergency Contact'),
                        subtitle: Text(
                          userProvider.spectrumProfile['emergency_contact']?.isNotEmpty == true
                              ? userProvider.spectrumProfile['emergency_contact']
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showEditContactDialog('emergency', userProvider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader('About'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('About Spectrum Support'),
                        subtitle: const Text('Learn more about this app'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showAboutDialog(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        subtitle: const Text('Get help using the app'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showHelpDialog(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _showEditProfileDialog(UserProvider userProvider) {
    final nameController = TextEditingController(text: userProvider.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.updateUserName(nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(String type, UserProvider userProvider) {
    final profile = userProvider.spectrumProfile;
    final nameController = TextEditingController(
      text: type == 'caregiver'
          ? profile['caregiver_name'] ?? ''
          : profile['emergency_contact'] ?? '',
    );
    final phoneController = TextEditingController(
      text: type == 'caregiver'
          ? profile['caregiver_phone'] ?? ''
          : profile['emergency_phone'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${type == 'caregiver' ? 'Caregiver' : 'Emergency Contact'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProfile = Map<String, dynamic>.from(profile);
              if (type == 'caregiver') {
                updatedProfile['caregiver_name'] = nameController.text;
                updatedProfile['caregiver_phone'] = phoneController.text;
              } else {
                updatedProfile['emergency_contact'] = nameController.text;
                updatedProfile['emergency_phone'] = phoneController.text;
              }
              userProvider.updateSpectrumProfile(updatedProfile);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Spectrum Support'),
        content: const Text(
          'Spectrum Support is designed specifically for autistic individuals and their caregivers to provide daily support, communication tools, and sensory management features.\n\nVersion: 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Need help using Spectrum Support?\n\n• Use the Emergency button for immediate help\n• Create custom routines in the Routines tab\n• Communicate using visual cards in the Communication tab\n• Manage sensory activities in the Sensory tab\n\nFor more support, contact your caregiver or emergency contact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
