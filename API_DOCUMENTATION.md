# Supportive Companion API Documentation

## Base URL
```
http://localhost:8000
```

## Quick Start for Flutter Team

### 1. Start the Backend Server
```bash
cd backend
python main.py
```

### 2. API Documentation
Visit: `http://localhost:8000/docs` for interactive API documentation

## Available Endpoints

### **Health Check**
- **GET** `/` - API status and features
- **GET** `/health` - Health check

### **User Profile**
- **POST** `/api/users/profile` - Create user profile
- **GET** `/api/users/{user_id}/profile` - Get user profile

### **Communication**
- **POST** `/api/communication/text-to-speech` - Convert text to speech
- **POST** `/api/communication/symbol-to-speech` - Convert symbols to speech

### **Daily Routines**
- **GET** `/api/routines/{user_id}` - Get user's daily routines
- **POST** `/api/routines/{user_id}/tasks` - Create new routine task
- **PUT** `/api/routines/{user_id}/tasks/{task_id}/complete` - Mark task complete

### **Memory Support**
- **GET** `/api/memory/{user_id}` - Get memory items
- **POST** `/api/memory/{user_id}/items` - Create memory item

### **Learning**
- **GET** `/api/learning/{user_id}/content` - Get learning content

### **Caregiver Dashboard**
- **GET** `/api/caregiver/{caregiver_id}/dashboard` - Get caregiver dashboard

## Request/Response Examples

### Create User Profile
```json
POST /api/users/profile
{
  "user_id": "user_123",
  "name": "Alex",
  "condition": "autism",
  "preferences": {
    "voice_enabled": true,
    "large_text": true,
    "high_contrast": true
  },
  "caregiver_id": "caregiver_456"
}
```

### Get Daily Routines
```json
GET /api/routines/user_123

Response:
{
  "user_id": "user_123",
  "routines": [
    {
      "task_id": "morning_1",
      "title": "Brush Teeth",
      "description": "Brush your teeth for 2 minutes",
      "time": "08:00",
      "completed": false,
      "image_url": "https://example.com/images/brush_teeth.png"
    }
  ]
}
```

### Symbol to Speech
```json
POST /api/communication/symbol-to-speech
{
  "user_id": "user_123",
  "message": "water",
  "type": "symbol_to_speech"
}

Response:
{
  "message": "Symbol converted to speech successfully",
  "audio_url": "https://api.example.com/audio/user_123/symbol.wav",
  "text": "I want water",
  "symbol": "water",
  "user_id": "user_123"
}
```

## Flutter Integration

### HTTP Client Setup
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  Future<Map<String, dynamic>> getUserRoutines(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/routines/$userId'),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load routines');
    }
  }
}
```

### Sample Usage in Flutter
```dart
// Get user routines
ApiService apiService = ApiService();
Map<String, dynamic> routines = await apiService.getUserRoutines('user_123');

// Convert symbol to speech
final response = await http.post(
  Uri.parse('$baseUrl/api/communication/symbol-to-speech'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({
    'user_id': 'user_123',
    'message': 'water',
    'type': 'symbol_to_speech'
  }),
);
```

## Available Mock Data

### Routine Tasks
- Brush Teeth (08:00)
- Eat Breakfast (08:30)
- Take Medicine (09:00)

### Memory Items
- Mom (family member)
- Dad (family member)
- Home Address (important info)

### Communication Symbols
- water → "I want water"
- food → "I am hungry"
- help → "I need help"
- bathroom → "I need to go to the bathroom"
- happy → "I am happy"
- sad → "I am sad"

## Next Steps

1. **Test the API** using the interactive docs at `http://localhost:8000/docs`
2. **Integrate with Flutter** using the examples above
3. **Add real features** as we develop them:
   - Firebase integration
   - Real text-to-speech
   - Image processing
   - User authentication

## Notes for Development

- All endpoints return mock data for now
- CORS is enabled for all origins (development only)
- Data is stored in memory (will be replaced with Firebase)
- Audio URLs are placeholder URLs

## Contact
If you need any changes to the API or have questions, let me know!
