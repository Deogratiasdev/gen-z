import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/question.dart';

class QuizStatsService {
  static final QuizStatsService _instance = QuizStatsService._internal();
  factory QuizStatsService() => _instance;
  QuizStatsService._internal();

  SupabaseClient get _client => SupabaseService().client;

  // Sauvegarder un résultat de QCM
  Future<void> saveQuizResult({
    required String category,
    required int totalQuestions,
    required int correctAnswers,
    required int score,
    required Duration duration,
    required List<QuestionAnswer> answers,
  }) async {
    final user = SupabaseService().currentUser;
    if (user == null) return;

    try {
      // Sauvegarder dans la table quiz_results
      await _client.from('quiz_results').insert({
        'user_id': user.id,
        'category': category,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'score': score,
        'duration_seconds': duration.inSeconds,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Mettre à jour les statistiques globales de l'utilisateur
      await _updateUserStats(user.id, correctAnswers, totalQuestions);
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la sauvegarde: $e');
    }
  }

  // Mettre à jour les statistiques de l'utilisateur
  Future<void> _updateUserStats(
    String userId,
    int correctAnswers,
    int totalQuestions,
  ) async {
    try {
      // Récupérer les stats actuelles
      final response = await _client
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Créer les stats initiales
        await _client.from('user_stats').insert({
          'user_id': userId,
          'total_quizzes': 1,
          'total_correct': correctAnswers,
          'total_questions': totalQuestions,
          'average_score': (correctAnswers / totalQuestions) * 100,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Mettre à jour les stats existantes
        final currentTotal = response['total_quizzes'] as int;
        final currentCorrect = response['total_correct'] as int;
        final currentQuestions = response['total_questions'] as int;

        final newTotal = currentTotal + 1;
        final newCorrect = currentCorrect + correctAnswers;
        final newQuestions = currentQuestions + totalQuestions;
        final newAverage = (newCorrect / newQuestions) * 100;

        await _client.from('user_stats').update({
          'total_quizzes': newTotal,
          'total_correct': newCorrect,
          'total_questions': newQuestions,
          'average_score': newAverage,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la mise à jour des stats: $e');
    }
  }

  // Récupérer les statistiques de l'utilisateur
  Future<Map<String, dynamic>?> getUserStats() async {
    final user = SupabaseService().currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('user_stats')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la récupération des stats: $e');
      return null;
    }
  }

  // Récupérer l'historique des QCM
  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final user = SupabaseService().currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('quiz_results')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }
}
