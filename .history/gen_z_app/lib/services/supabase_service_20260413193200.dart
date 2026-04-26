import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://zvfmfaxtwicheoypngaa.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2Zm1mYXh0d2ljaGVveXBuZ2FhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwOTg5MzQsImV4cCI6MjA5MTY3NDkzNH0.ZyG0ldZjMGQSYUqhIF98AxeQuB0fuzIp2XWFJdG_scA',
    );
  }

  // Auth: Email + Password avec logique intelligente
  Future<AuthResponse> signInOrSignUp(String email, String password) async {
    try {
      // Essayer d'abord la connexion
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      // Si échec connexion, essayer l'inscription
      if (e.message.contains('Invalid login credentials')) {
        final response = await client.auth.signUp(
          email: email,
          password: password,
        );
        return response;
      }
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Utilisateur actuel
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Session
  Session? get currentSession => client.auth.currentSession;
}
