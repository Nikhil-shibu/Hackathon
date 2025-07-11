# Thrive Mind - Authentication System

## Overview

The authentication system provides secure login and registration functionality with accessibility-first design principles. The system includes comprehensive user registration with disability-specific information for personalized app experience.

## Features

### Login Screen (`/lib/screens/auth/login_screen.dart`)
- **Email-based login** (email serves as username)
- **Password authentication** with visibility toggle
- **Large, accessible form elements** (60px button height minimum)
- **Clear error messaging** and validation
- **Forgot password placeholder** (for future implementation)
- **Create account navigation**
- **Accessible design** with proper semantic labels

### Create Account Screen (`/lib/screens/auth/create_account_screen.dart`)
- **Comprehensive user information collection**:
  - Full Name (minimum 2 characters)
  - Age (1-120 years)
  - Mobile Number (minimum 10 digits)
  - Email Address (serves as username)
  - Gender selection (Male, Female, Other, Prefer not to say)
  - **Specially Abled dropdown** with 4 specific conditions:
    1. Down Syndrome
    2. Autism
    3. Dementia
    4. Dyslexia
  - Password with confirmation
- **Input validation** for all fields
- **Accessibility features**:
  - Large touch targets
  - Clear visual feedback
  - High contrast design
  - Descriptive labels

## User Flow

1. **App Launch** → Login Screen
2. **New User** → Create Account Screen → Registration → Success Dialog → Home Screen
3. **Existing User** → Login Screen → Authentication → Home Screen
4. **Authenticated User** → Home Screen with logout option

## Data Collection

### User Profile Fields
```dart
{
  "fullName": String,
  "age": int,
  "mobileNumber": String,
  "email": String, // Used as username
  "gender": String,
  "speciallyAbled": String, // One of: Down Syndrome, Autism, Dementia, Dyslexia
  "password": String (hashed)
}
```

### Disability Options
The app specifically supports individuals with:
1. **Down Syndrome** - Genetic condition affecting learning and development
2. **Autism** - Neurodevelopmental condition affecting communication and behavior
3. **Dementia** - Group of conditions affecting memory and cognitive function
4. **Dyslexia** - Learning difficulty affecting reading and language processing

## Accessibility Features

### Design Principles
- **Large Text**: Minimum 18px font size
- **High Contrast**: Clear color differentiation
- **Large Touch Targets**: Minimum 60px button height
- **Clear Navigation**: Simple, logical flow
- **Visual Feedback**: Immediate response to user actions
- **Error Handling**: Clear, helpful error messages

### Form Accessibility
- **Semantic Labels**: Proper labeling for screen readers
- **Input Validation**: Real-time validation with clear messages
- **Password Visibility**: Toggle for password fields
- **Dropdown Accessibility**: Large, easy-to-select options

## Security Features

### Password Requirements
- Minimum 6 characters
- Confirmation required during registration
- Visibility toggle for easier input

### Validation
- Email format validation
- Age range validation (1-120)
- Mobile number length validation
- Required field validation
- Password confirmation matching

## Future Enhancements

### Planned Features
1. **Forgot Password** functionality
2. **Two-factor authentication**
3. **Biometric login** (fingerprint/face ID)
4. **Social login** options
5. **Profile picture** upload
6. **Emergency contact** information
7. **Caregiver account** linking

### Backend Integration
- User registration API
- Authentication API
- Profile management API
- Password reset API
- Session management

## Testing

### Current Tests
- App launch and login screen display
- Form validation
- Navigation between screens

### Recommended Tests
- User registration flow
- Login authentication flow
- Form validation edge cases
- Accessibility testing with screen readers
- Cross-platform compatibility

## Usage Instructions

### For Developers
1. Import authentication screens in your navigation
2. Handle authentication state management
3. Implement secure storage for user credentials
4. Add backend API integration

### For Users
1. **New Users**: Click "Create New Account" and fill all required fields
2. **Existing Users**: Enter email and password to login
3. **Password Issues**: Use "Forgot Password" (coming soon)

## Code Structure

```
lib/screens/auth/
├── login_screen.dart          # Main login interface
├── create_account_screen.dart # Registration form
└── ...                        # Future auth screens

lib/screens/
├── home_screen.dart          # Post-login main screen
└── ...
```

This authentication system provides a solid foundation for a secure, accessible, and user-friendly login experience specifically designed for individuals with various abilities and their caregivers.
