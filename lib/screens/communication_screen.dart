import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/modern_theme.dart';
import '../widgets/modern_components.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  final List<String> _selectedWords = [];
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;
  
  // Communication categories and words
  final Map<String, List<CommunicationItem>> _communicationCategories = {
    'Feelings': [
      CommunicationItem('Happy', Icons.sentiment_very_satisfied, Colors.yellow),
      CommunicationItem('Sad', Icons.sentiment_very_dissatisfied, Colors.blue),
      CommunicationItem('Angry', Icons.sentiment_very_dissatisfied, Colors.red),
      CommunicationItem('Excited', Icons.sentiment_very_satisfied, Colors.orange),
      CommunicationItem('Tired', Icons.bedtime, Colors.purple),
      CommunicationItem('Scared', Icons.sentiment_neutral, Colors.grey),
    ],
    'Needs': [
      CommunicationItem('Water', Icons.local_drink, Colors.blue),
      CommunicationItem('Food', Icons.restaurant, Colors.orange),
      CommunicationItem('Bathroom', Icons.wc, Colors.brown),
      CommunicationItem('Help', Icons.help, Colors.red),
      CommunicationItem('Break', Icons.pause, Colors.green),
      CommunicationItem('Quiet', Icons.volume_off, Colors.grey),
    ],
    'Activities': [
      CommunicationItem('Play', Icons.toys, Colors.pink),
      CommunicationItem('Read', Icons.book, Colors.blue),
      CommunicationItem('Music', Icons.music_note, Colors.purple),
      CommunicationItem('Walk', Icons.directions_walk, Colors.green),
      CommunicationItem('TV', Icons.tv, Colors.black),
      CommunicationItem('Sleep', Icons.bed, Colors.indigo),
    ],
  };

  String _selectedCategory = 'Feelings';

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);
    
    // Set completion handler
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModernBackground(
      animated: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: ModernAppBar(
          title: 'Communication',
          leading: ModernBackButton(),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_voice),
              onPressed: _showVoiceSettings,
              tooltip: 'Voice Settings',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Selected words display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ModernTheme.spacingLarge),
              margin: const EdgeInsets.all(ModernTheme.spacing),
              decoration: ModernTheme.elevatedCardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Message:',
                    style: ModernTheme.headingSmall,
                  ),
                  const SizedBox(height: ModernTheme.spacing),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(ModernTheme.spacing),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _selectedWords.isEmpty 
                        ? 'Tap words below to build your message'
                        : _selectedWords.join(' '),
                      style: ModernTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: ModernTheme.spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectedWords.isNotEmpty ? _clearMessage : null,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ModernTheme.errorColor.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: ModernTheme.errorColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _selectedWords.isNotEmpty ? _speakMessage : null,
                        icon: _isSpeaking 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.volume_up),
                        label: Text(_isSpeaking ? 'Speaking...' : 'Speak'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSpeaking 
                            ? ModernTheme.successColor.withOpacity(0.3)
                            : ModernTheme.primaryColor.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _isSpeaking 
                                ? ModernTheme.successColor.withOpacity(0.4)
                                : ModernTheme.primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Category selector
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: ModernTheme.spacing),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _communicationCategories.keys.length,
                itemBuilder: (context, index) {
                  final category = _communicationCategories.keys.elementAt(index);
                  final isSelected = category == _selectedCategory;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected 
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Text(
                          category,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Communication items grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ModernTheme.spacing),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: ModernTheme.spacing,
                    mainAxisSpacing: ModernTheme.spacing,
                  ),
                  itemCount: _communicationCategories[_selectedCategory]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = _communicationCategories[_selectedCategory]![index];
                    return _buildCommunicationCard(item);
                  },
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunicationCard(CommunicationItem item) {
    return Container(
      decoration: ModernTheme.glassCardDecoration,
      child: InkWell(
        onTap: () => _addWordToMessage(item.word),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(ModernTheme.spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: ModernTheme.spacingSmall),
              Text(
                item.word,
                style: ModernTheme.bodyLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addWordToMessage(String word) {
    setState(() {
      _selectedWords.add(word);
    });
    
    // Provide audio feedback - speak the word
    _speakWord(word);
    
    // Show brief feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$word" to message'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _clearMessage() {
    setState(() {
      _selectedWords.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message cleared'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _speakMessage() async {
    if (_selectedWords.isEmpty || _isSpeaking) return;
    
    final message = _selectedWords.join(' ');
    
    setState(() {
      _isSpeaking = true;
    });
    
    try {
      await _flutterTts.speak(message);
    } catch (e) {
      print('Error speaking message: $e');
      // Fallback: show dialog if TTS fails
      _showSpeakDialog(message);
    }
  }
  
  Future<void> _speakWord(String word) async {
    try {
      // Stop any current speech
      await _flutterTts.stop();
      // Speak the individual word
      await _flutterTts.speak(word);
    } catch (e) {
      print('Error speaking word: $e');
    }
  }
  
  void _showSpeakDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speaking Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.volume_up, size: 48),
            const SizedBox(height: 16),
            Text(
              '"$message"',
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Text-to-speech not available on this device',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    
    setState(() {
      _isSpeaking = false;
    });
  }

  void _showVoiceSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Voice Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Speech rate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Speech Rate'),
                  Slider(
                    value: _speechRate,
                    onChanged: (value) {
                      setState(() {
                        _speechRate = value;
                      });
                      _flutterTts.setSpeechRate(value);
                    },
                    min: 0.1,
                    max: 1.0,
                    divisions: 10,
                    label: _speechRate.toStringAsFixed(1),
                  ),
                ],
              ),

              // Volume
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Volume'),
                  Slider(
                    value: _volume,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                      _flutterTts.setVolume(value);
                    },
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _volume.toStringAsFixed(1),
                  ),
                ],
              ),

              // Pitch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pitch'),
                  Slider(
                    value: _pitch,
                    onChanged: (value) {
                      setState(() {
                        _pitch = value;
                      });
                      _flutterTts.setPitch(value);
                    },
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: _pitch.toStringAsFixed(1),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class CommunicationItem {
  final String word;
  final IconData icon;
  final Color color;

  CommunicationItem(this.word, this.icon, this.color);
}
