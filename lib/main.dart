import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_dashboard.dart';
import 'providers/user_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/communication_provider.dart';
import 'providers/sensory_provider.dart';
import 'providers/routine_provider.dart';
import 'utils/app_theme.dart';
import 'utils/accessibility_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize accessibility services
  await AccessibilityUtils.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SpectrumSupportApp());
}

class SpectrumSupportApp extends StatelessWidget {
  const SpectrumSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CommunicationProvider()),
        ChangeNotifierProvider(create: (_) => SensoryProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Spectrum Support',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const AppInitializer(),
            // Enhanced accessibility
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: settings.textScale,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize providers
      await context.read<UserProvider>().initialize();
      await context.read<SettingsProvider>().initialize();
      await context.read<CommunicationProvider>().initialize();
      await context.read<SensoryProvider>().initialize();
      await context.read<RoutineProvider>().initialize();
      
      // Check if user has completed setup
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedSetup = prefs.getBool('has_completed_setup') ?? false;
      
      setState(() {
        _isFirstLaunch = !hasCompletedSetup;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing app: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen();
    }

    if (_isFirstLaunch) {
      return const WelcomeScreen();
    }

    return const MainDashboard();
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Spectrum Support',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading your personalized experience...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
