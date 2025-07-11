import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/condition_selection_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ThriveMindApp());
}

class ThriveMindApp extends StatelessWidget {
  const ThriveMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thrive Mind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // High contrast accessibility theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Calming green
          brightness: Brightness.light,
        ),
        // Large, accessible text sizes
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 18),
        ),
        // Large touch targets for accessibility
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 80),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/condition-selection': (context) => const ConditionSelectionScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

