import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  SupabaseClient get _client => SupabaseService().client;

  // Emails des admins
  static const List<String> adminEmails = [
    'chadareandy@gmail.com',
    'deogratiashounnou1@gmail.com',
  ];

  // Vérifier si l'utilisateur connecté est admin
  bool get isCurrentUserAdmin {
    final email = SupabaseService().currentUser?.email;
    return email != null && adminEmails.contains(email);
  }

  // Obtenir tous les utilisateurs (fonction SQL)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _client.rpc('get_all_users');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir les stats de tous les utilisateurs
  Future<List<Map<String, dynamic>>> getAllUsersStats() async {
    try {
      final response = await _client.rpc('get_all_users_stats');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir tous les résultats de QCM
  Future<List<Map<String, dynamic>>> getAllQuizResults() async {
    try {
      final response = await _client.rpc('get_all_quiz_results');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir les stats globales
  Future<Map<String, dynamic>?> getGlobalStats() async {
    try {
      final response = await _client.rpc('get_global_stats');
      if (response is List && response.isNotEmpty) {
        return Map<String, dynamic>.from(response[0]);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    try {
      await _client.rpc('delete_user', params: {'target_user_id': userId});
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
