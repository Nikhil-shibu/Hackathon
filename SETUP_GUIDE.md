# Thrive Mind Setup Guide

## Overview
Thrive Mind is a supportive companion app for individuals with Autism, Down Syndrome, Dementia, and learning disabilities.

## Prerequisites
- Flutter SDK (3.3.0 or later)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (API level 23 or higher)
- Google Cloud Console account (for Maps API)

## Setup Instructions

### 1. Google Maps API Key Setup

The app uses Google Maps for location-based safety features. You need to set up a Google Maps API key:

1. **Create a Google Cloud Project:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one

2. **Enable Google Maps SDK:**
   - Navigate to "APIs & Services" > "Library"
   - Search for "Maps SDK for Android"
   - Click "Enable"

3. **Create API Key:**
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "API Key"
   - Copy the generated API key

4. **Configure API Key in App:**
   - Open `android/app/src/main/AndroidManifest.xml`
   - Find the line: `android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

5. **Restrict API Key (Recommended):**
   - In Google Cloud Console, click on your API key
   - Under "Application restrictions", select "Android apps"
   - Add your app's package name: `com.example.thrive_mind`
   - Add your SHA-1 certificate fingerprint

### 2. Firebase Setup

The app uses Firebase for authentication and data storage:

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project

2. **Add Android App:**
   - Click "Add app" > Android
   - Package name: `com.example.thrive_mind`
   - Download `google-services.json`
   - Place it in `android/app/` directory

3. **Enable Authentication:**
   - In Firebase Console, go to "Authentication"
   - Enable "Email/Password" sign-in method

4. **Enable Firestore:**
   - Go to "Firestore Database"
   - Create database in production mode

### 3. Building and Running

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the App:**
   ```bash
   flutter run
   ```

## Features

### For All Users:
- **Communication Tools:** Picture-based communication system
- **User-friendly Interface:** Large buttons, clear navigation
- **Voice Support:** Text-to-speech functionality
- **Accessibility:** High contrast themes, customizable text sizes

### Dementia-Specific Features:
- **Daily Routine Management:** Visual schedules and reminders
- **Memory Book:** Photo albums with voice recordings
- **Medication Reminders:** Simple, clear medication tracking
- **Safety Features:** Location tracking and emergency contacts
- **Family Communication:** Easy calling and messaging
- **Cognitive Stimulation:** Memory games and exercises

### Autism Support:
- **Sensory Tools:** Calming interfaces and sounds
- **Communication Aids:** Symbol-based communication
- **Routine Support:** Visual schedules and timers

### Down Syndrome Support:
- **Learning Tools:** Educational games and activities
- **Communication Aids:** Picture and text communication

## Troubleshooting

### Common Issues:

1. **"API key not found" Error:**
   - Ensure you've replaced the placeholder API key in AndroidManifest.xml
   - Verify the API key is correctly formatted

2. **Location Permission Errors:**
   - The app automatically requests location permissions
   - Grant permissions when prompted for safety features to work

3. **Firebase Authentication Issues:**
   - Ensure `google-services.json` is in the correct location
   - Verify Firebase project configuration

4. **Build Issues:**
   - Run `flutter clean` and `flutter pub get`
   - Ensure Android SDK is properly configured

## Security Notes

- Never commit API keys to version control
- Use environment variables or secure config files for production
- Regularly rotate API keys
- Monitor API usage in Google Cloud Console

## Support

For issues and feature requests, please check the project documentation or contact the development team.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
