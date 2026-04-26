import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/theme_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await SupabaseService.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const GenZQuizApp());
}

class GenZQuizApp extends StatelessWidget {
  const GenZQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider();

    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, child) {
        // Mettre à jour le style de la barre système selon le thème
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: themeProvider.isDarkMode
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarColor: themeProvider.background,
            systemNavigationBarIconBrightness: themeProvider.isDarkMode
                ? Brightness.light
                : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Gen Z Quiz',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          darkTheme: themeProvider.themeData,
          themeMode: ThemeMode.system,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

// Widget qui vérifie l'état d'authentification et redirige
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // Petit délai pour laisser Supabase initialiser
    await Future.delayed(const Duration(milliseconds: 500));

    final user = Supabase.instance.client.auth.currentUser;

    if (mounted) {
      setState(() {
        _isAuthenticated = user != null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
        ),
      );
    }

    // Rediriger vers Home si connecté, sinon Welcome
    return _isAuthenticated ? const HomeScreen() : const WelcomeScreen();
  }
}
