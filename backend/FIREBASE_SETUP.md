# Firebase Setup Instructions

## Quick Setup for Hackathon

### Option 1: Firebase Console Setup (Recommended)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Create a new project or use existing one

2. **Enable Required Services**
   - **Firestore Database**: Go to Firestore Database → Create database → Start in test mode
   - **Storage**: Go to Storage → Get started → Start in test mode
   - **Authentication**: Go to Authentication → Get started (optional for now)

3. **Generate Service Account Key**
   - Go to Project Settings (gear icon)
   - Click "Service accounts" tab
   - Click "Generate new private key"
   - Download the JSON file
   - Save it as `service-account-key.json` in your backend folder

4. **Update Environment Variables**
   ```bash
   # Update .env file
   FIREBASE_SERVICE_ACCOUNT_PATH=./service-account-key.json
   FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
   FIREBASE_PROJECT_ID=your-project-id
   ```

### Option 2: Firebase CLI Setup (Alternative)

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Initialize Firebase**
   ```bash
   firebase init
   # Select: Firestore, Storage, Functions (optional)
   ```

4. **Start Firebase Emulator (for local development)**
   ```bash
   firebase emulators:start
   ```

## Testing Firebase Connection

1. **Start your backend server**
   ```bash
   python main.py
   ```

2. **Check console output**
   - ✅ "Firebase initialized successfully!" = Working
   - ❌ "Firebase initialization failed" = Check setup

3. **Test API endpoints**
   - Visit: http://localhost:8000/docs
   - Try creating a user profile
   - Check if data is saved in Firebase Console

## Firestore Database Structure

```
users/
  └── {user_id}/
      ├── name: string
      ├── condition: string
      ├── preferences: object
      ├── caregiver_id: string
      ├── created_at: timestamp
      └── routines/
          └── {task_id}/
              ├── title: string
              ├── description: string
              ├── time: string
              ├── completed: boolean
              └── image_url: string
      └── memory/
          └── {item_id}/
              ├── title: string
              ├── description: string
              ├── image_url: string
              └── reminder_time: string
```

## Storage Structure

```
storage/
├── user_images/
│   └── {user_id}/
│       ├── profile.jpg
│       └── memory_photos/
├── routine_images/
│   └── {task_id}.jpg
└── audio_files/
    └── {user_id}/
        └── speech_output.wav
```

## Security Rules (For Production)

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcollections inherit the same rules
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Caregivers can access their patients' data
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        resource.data.caregiver_id == request.auth.uid;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /user_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **"Firebase initialization failed"**
   - Check if service account key file exists
   - Verify file path in .env
   - Ensure project ID is correct

2. **"Permission denied"**
   - Check Firestore rules
   - Ensure test mode is enabled for hackathon

3. **"Quota exceeded"**
   - Firebase free tier limits reached
   - Use Firebase emulator for local testing

### Debug Mode

Add this to your main.py to debug Firebase issues:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## For Hackathon Development

**Quick Start (No Authentication)**
1. Use test mode for Firestore and Storage
2. Skip authentication for now
3. Use service account key for simplicity
4. Focus on core features first

**Production Considerations**
1. Enable authentication
2. Set up proper security rules
3. Use environment-based configuration
4. Add error handling and logging

## Environment Variables Reference

```bash
# Required
FIREBASE_SERVICE_ACCOUNT_PATH=./service-account-key.json
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_PROJECT_ID=your-project-id

# Optional
DEBUG=True
ENVIRONMENT=development
```

## Next Steps

1. ✅ Set up Firebase project
2. ✅ Configure service account
3. ✅ Test database connection
4. 🔄 Add real-time features
5. 🔄 Implement file upload
6. 🔄 Add user authentication (if needed)

Need help with any step? Let me know!
