import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunicationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _communicationCards = [];
  List<Map<String, dynamic>> _phrases = [];
  List<Map<String, dynamic>> _emotionCards = [];
  
  List<Map<String, dynamic>> get communicationCards => _communicationCards;
  List<Map<String, dynamic>> get phrases => _phrases;
  List<Map<String, dynamic>> get emotionCards => _emotionCards;

  Future<void> initialize() async {
    await _loadDefaultCards();
    notifyListeners();
  }

  Future<void> _loadDefaultCards() async {
    // Load default communication cards
    _communicationCards = [
      {
        'id': '1',
        'title': 'I want',
        'symbol': '🙋',
        'category': 'needs',
        'isCustom': false,
      },
      {
        'id': '2',
        'title': 'Help me',
        'symbol': '🆘',
        'category': 'needs',
        'isCustom': false,
      },
      {
        'id': '3',
        'title': 'Thank you',
        'symbol': '🙏',
        'category': 'social',
        'isCustom': false,
      },
      {
        'id': '4',
        'title': 'Yes',
        'symbol': '✅',
        'category': 'responses',
        'isCustom': false,
      },
      {
        'id': '5',
        'title': 'No',
        'symbol': '❌',
        'category': 'responses',
        'isCustom': false,
      },
    ];

    // Load default emotion cards
    _emotionCards = [
      {
        'id': '1',
        'emotion': 'Happy',
        'symbol': '😊',
        'color': 0xFF4CAF50,
      },
      {
        'id': '2',
        'emotion': 'Sad',
        'symbol': '😢',
        'color': 0xFF2196F3,
      },
      {
        'id': '3',
        'emotion': 'Angry',
        'symbol': '😠',
        'color': 0xFFF44336,
      },
      {
        'id': '4',
        'emotion': 'Excited',
        'symbol': '🤩',
        'color': 0xFFFF9800,
      },
      {
        'id': '5',
        'emotion': 'Calm',
        'symbol': '😌',
        'color': 0xFF9C27B0,
      },
    ];

    // Load default phrases
    _phrases = [
      {
        'id': '1',
        'text': 'I need a break',
        'category': 'sensory',
        'isCustom': false,
      },
      {
        'id': '2',
        'text': 'Too loud',
        'category': 'sensory',
        'isCustom': false,
      },
      {
        'id': '3',
        'text': 'I don\'t understand',
        'category': 'social',
        'isCustom': false,
      },
      {
        'id': '4',
        'text': 'Can you repeat that?',
        'category': 'social',
        'isCustom': false,
      },
    ];
  }

  Future<void> addCustomCard(Map<String, dynamic> card) async {
    card['isCustom'] = true;
    _communicationCards.add(card);
    notifyListeners();
  }

  Future<void> addCustomPhrase(Map<String, dynamic> phrase) async {
    phrase['isCustom'] = true;
    _phrases.add(phrase);
    notifyListeners();
  }

  Future<void> removeCard(String id) async {
    _communicationCards.removeWhere((card) => card['id'] == id);
    notifyListeners();
  }

  Future<void> removePhrase(String id) async {
    _phrases.removeWhere((phrase) => phrase['id'] == id);
    notifyListeners();
  }

  List<Map<String, dynamic>> getCardsByCategory(String category) {
    return _communicationCards.where((card) => card['category'] == category).toList();
  }

  List<Map<String, dynamic>> getPhrasesByCategory(String category) {
    return _phrases.where((phrase) => phrase['category'] == category).toList();
  }
}
