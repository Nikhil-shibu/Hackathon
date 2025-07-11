import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/communication_provider.dart';
import '../utils/app_theme.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  List<Map<String, dynamic>> _selectedCards = [];
  String _builtSentence = '';
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Communication'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSentence,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sentence Builder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'My Message',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 60),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedCards.map((card) {
                      return Chip(
                        label: Text(card['title']),
                        avatar: Text(card['symbol']),
                        onDeleted: () => _removeFromSentence(card),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectedCards.isNotEmpty && !_isSpeaking ? _speakSentence : null,
                        icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                        label: Text(_isSpeaking ? 'Stop' : 'Speak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectedCards.isNotEmpty ? _clearSentence : null,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Communication Cards
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.textSecondaryColor,
                    tabs: const [
                      Tab(text: 'Needs', icon: Icon(Icons.help_outline)),
                      Tab(text: 'Social', icon: Icon(Icons.people)),
                      Tab(text: 'Responses', icon: Icon(Icons.chat)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCommunicationGrid('needs'),
                        _buildCommunicationGrid('social'),
                        _buildCommunicationGrid('responses'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationGrid(String category) {
    return Consumer<CommunicationProvider>(
      builder: (context, provider, child) {
        final cards = provider.getCardsByCategory(category);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _buildCommunicationCard(card);
          },
        );
      },
    );
  }

  Widget _buildEmotionGrid() {
    return Consumer<CommunicationProvider>(
      builder: (context, provider, child) {
        final emotions = provider.emotionCards;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: emotions.length,
          itemBuilder: (context, index) {
            final emotion = emotions[index];
            return _buildEmotionCard(emotion);
          },
        );
      },
    );
  }

  Widget _buildCommunicationCard(Map<String, dynamic> card) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addToSentence(card),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card['symbol'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                card['title'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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

  Widget _buildEmotionCard(Map<String, dynamic> emotion) {
    final color = Color(emotion['color']);
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addEmotionToSentence(emotion),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emotion['symbol'],
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                emotion['emotion'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
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

  void _addToSentence(Map<String, dynamic> card) {
    setState(() {
      _selectedCards.add(card);
      _builtSentence = _selectedCards.map((c) => c['title']).join(' ');
    });
    HapticFeedback.lightImpact();
  }

  void _addEmotionToSentence(Map<String, dynamic> emotion) {
    final card = {
      'id': emotion['id'],
      'title': 'I feel ${emotion['emotion']}',
      'symbol': emotion['symbol'],
      'category': 'emotion',
    };
    _addToSentence(card);
  }

  void _removeFromSentence(Map<String, dynamic> card) {
    setState(() {
      _selectedCards.remove(card);
      _builtSentence = _selectedCards.map((c) => c['title']).join(' ');
    });
    HapticFeedback.lightImpact();
  }

  void _clearSentence() {
    setState(() {
      _selectedCards.clear();
      _builtSentence = '';
    });
    HapticFeedback.lightImpact();
  }

  void _speakSentence() async {
    if (_builtSentence.isNotEmpty) {
      if (_isSpeaking) {
        await _flutterTts.stop();
        setState(() {
          _isSpeaking = false;
        });
      } else {
        setState(() {
          _isSpeaking = true;
        });
        
        try {
          await _flutterTts.speak(_builtSentence);
          HapticFeedback.mediumImpact();
        } catch (e) {
          // Fallback to showing text if TTS fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speaking: "$_builtSentence"'),
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {
            _isSpeaking = false;
          });
        }
      }
    }
  }
}
