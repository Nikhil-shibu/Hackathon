# Thrive Mind - Development Guide

## Project Structure

```
thrive_mind/
├── lib/
│   ├── main.dart                 # Main app entry point
│   ├── screens/                  # App screens
│   │   └── communication_screen.dart
│   ├── widgets/                  # Reusable widgets (future)
│   ├── models/                   # Data models (future)
│   └── services/                 # Services (future)
├── assets/
│   ├── images/                   # App images
│   └── icons/                    # App icons (future)
├── test/                         # Unit tests
├── docs/                         # Documentation
├── pubspec.yaml                  # Dependencies
├── Makefile                      # Build commands
└── README.md                     # Project overview
```

## Development Setup

1. **Install Flutter**: Ensure Flutter SDK is installed and configured
2. **Clone Repository**: `git clone <repository-url>`
3. **Install Dependencies**: `flutter pub get` or `make install`
4. **Run App**: `flutter run -d web-server --web-port 8080` or `make run-web`

## Accessibility Features

### Current Implementation
- Large, clear text sizes (18px+)
- High contrast color scheme
- Large touch targets (minimum 80x80px)
- Clear visual hierarchy
- Semantic labels for screen readers
- Simple navigation patterns

### Future Enhancements
- Text-to-speech integration
- Speech recognition
- Customizable theme options
- Picture-based navigation
- Simplified language options
- Haptic feedback

## Features

### Communication Tool
- **Location**: `lib/screens/communication_screen.dart`
- **Purpose**: Help users express needs, feelings, and desires
- **Features**:
  - Category-based word selection (Feelings, Needs, Activities)
  - Visual word cards with icons and colors
  - Message building interface
  - Clear and speak functionality
  - Large, accessible buttons

### Planned Features
1. **Daily Routine Manager**
   - Visual schedules
   - Time-based reminders
   - Progress tracking
   
2. **Memory Helper**
   - Important reminders
   - Photo-based memory aids
   - Simple note-taking
   
3. **Learning Assistant**
   - Interactive exercises
   - Progress tracking
   - Adaptive difficulty

## Design Principles

1. **Simplicity**: Clear, uncluttered interface
2. **Consistency**: Uniform design patterns throughout
3. **Accessibility**: WCAG 2.1 AA compliance
4. **Empowerment**: Foster independence and confidence
5. **Compassion**: Respectful and supportive user experience

## Code Style

- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments for complex logic
- Implement proper error handling
- Write accessible code with semantic labels

## Testing

- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- Accessibility testing with screen readers

## Build Commands

Use the Makefile for common tasks:
- `make install` - Install dependencies
- `make run-web` - Run on web server
- `make build-web` - Build for web deployment
- `make test` - Run tests
- `make format` - Format code
- `make analyze` - Analyze code
- `make help` - Show all available commands

## Contributing

1. Follow accessibility guidelines
2. Test with screen readers
3. Maintain large touch targets
4. Use clear, simple language
5. Consider cognitive load in design decisions
