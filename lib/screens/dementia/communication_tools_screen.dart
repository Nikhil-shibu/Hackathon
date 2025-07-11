import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CommunicationToolsScreen extends StatefulWidget {
  const CommunicationToolsScreen({super.key});

  @override
  State<CommunicationToolsScreen> createState() => _CommunicationToolsScreenState();
}

class _CommunicationToolsScreenState extends State<CommunicationToolsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _recognizedText = '';
  
  // User-customizable emergency contacts
  List<EmergencyContact> _emergencyContacts = [];
  
  // User-customizable emotion-based messages
  List<QuickMessage> _quickMessages = [];
  
  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeSpeech();
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
  
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  
  Future<void> _initializeSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
    } catch (e) {
      print('Speech recognition not available: $e');
      _speechEnabled = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Call Family & Express Feelings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Go back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white, size: 28),
            onPressed: _showManageContactsDialog,
            tooltip: 'Manage Contacts',
          ),
          Container(
            margin: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () => _triggerEmergency(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.emergency, size: 20),
                  SizedBox(width: 4),
                  Text('HELP', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF7B68EE),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Voice Input Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 40,
                        color: _isListening ? Colors.red : Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Voice Communication',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isListening 
                            ? 'Listening... Speak now'
                            : (_recognizedText.isEmpty 
                                ? 'Tap to speak or choose a message below'
                                : _recognizedText),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _speechEnabled ? _startListening : null,
                            icon: Icon(_isListening ? Icons.stop : Icons.mic),
                            label: Text(_isListening ? 'Stop' : 'Speak'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening ? Colors.red : Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          if (_recognizedText.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () => _speakText(_recognizedText),
                              icon: const Icon(Icons.volume_up),
                              label: const Text('Repeat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Emergency Contacts Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emergency, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            'Emergency Contacts',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_emergencyContacts.where((contact) => contact.isEmergency).isEmpty)
                        Text(
                          'No emergency contacts added yet',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        )
                      else
                        ...(_emergencyContacts.where((contact) => contact.isEmergency).map(
                          (contact) => _buildEmergencyContactButton(contact),
                        )),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // All Contacts Section
                Text(
                  'Call Someone',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                if (_emergencyContacts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.person_add, size: 48, color: Colors.white.withOpacity(0.6)),
                        const SizedBox(height: 12),
                        Text(
                          'No contacts added yet',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + icon to add family and friends',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...(_emergencyContacts.map(
                    (contact) => _buildContactCard(contact),
                  )),
                
                const SizedBox(height: 20),
                
                // Quick Messages Section
                Text(
                  'Quick Messages',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                if (_quickMessages.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.message, size: 48, color: Colors.white.withOpacity(0.6)),
                        const SizedBox(height: 12),
                        Text(
                          'No quick messages yet',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add custom messages for easy communication',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _quickMessages.length,
                    itemBuilder: (context, index) {
                      final message = _quickMessages[index];
                      return _buildQuickMessageButton(message);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmergencyContactButton(EmergencyContact contact) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () => _callContact(contact),
        style: ElevatedButton.styleFrom(
          backgroundColor: contact.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(contact.icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    contact.phone,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.call, size: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: contact.color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            contact.icon,
            size: 28,
            color: Colors.white,
          ),
        ),
        title: Text(
          contact.name,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.relationship,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              contact.phone,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.blue, size: 28),
              onPressed: () => _videoCall(contact),
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green, size: 28),
              onPressed: () => _callContact(contact),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickMessageButton(QuickMessage message) {
    return GestureDetector(
      onTap: () => _sendQuickMessage(message),
      child: Container(
        decoration: BoxDecoration(
          color: message.color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              message.icon,
              size: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _startListening() async {
    if (!_speechEnabled) {
      _speakText('Speech recognition is not available on this device.');
      return;
    }
    
    if (!_isListening) {
      try {
        bool available = await _speechToText.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
        );
        
        if (available) {
          setState(() {
            _isListening = true;
          });
        }
      } catch (e) {
        print('Error starting speech recognition: $e');
        _speakText('Could not start speech recognition.');
      }
    } else {
      setState(() {
        _isListening = false;
      });
      try {
        _speechToText.stop();
      } catch (e) {
        print('Error stopping speech recognition: $e');
      }
    }
  }
  
  void _callContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.call, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Text('Call ${contact.name}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: contact.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(contact.icon, color: contact.color, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(contact.relationship),
                        Text(
                          contact.phone,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Would you like to call this person?',
              style: TextStyle(fontSize: 16),
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
              Navigator.pop(context);
              _makeCall(contact);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }
  
  void _videoCall(EmergencyContact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting video call with ${contact.name}...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _makeCall(EmergencyContact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${contact.name} at ${contact.phone}...'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _sendQuickMessage(QuickMessage message) async {
    await _speakText(message.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(message.icon, color: Colors.white),
            const SizedBox(width: 12),
            Text('Said: "${message.text}"'),
          ],
        ),
        backgroundColor: message.color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _triggerEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.emergency, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Emergency Help', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will send an emergency alert to all your caregivers and contact emergency services.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendEmergencyAlert();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Emergency Alert'),
          ),
        ],
      ),
    );
  }
  
  void _sendEmergencyAlert() {
    // Show emergency alert animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Sending emergency alert...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
    
    // Simulate emergency alert
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert sent to all caregivers!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    });
  }
  
  Future<void> _speakText(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  void _showManageContactsDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController relationshipController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Manage Contacts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  setState(() {
                    _emergencyContacts.add(
                      EmergencyContact(
                        name: nameController.text,
                        phone: phoneController.text,
                        icon: Icons.person,
                        color: Colors.blue,
                        relationship: relationshipController.text.isEmpty ? 'Contact' : relationshipController.text,
                        isEmergency: false,
                      ),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contact "${nameController.text}" added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add Contact'),
            ),
          ],
        );
      },
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final IconData icon;
  final Color color;
  final String relationship;
  final bool isEmergency;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.icon,
    required this.color,
    required this.relationship,
    required this.isEmergency,
  });
}

class QuickMessage {
  final String text;
  final IconData icon;
  final Color color;
  final String category;

  QuickMessage({
    required this.text,
    required this.icon,
    required this.color,
    required this.category,
  });
}
