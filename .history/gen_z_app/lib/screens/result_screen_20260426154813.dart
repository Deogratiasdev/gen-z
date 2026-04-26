// ============================================================================
// ÉCRAN DES RÉSULTATS FINAUX
// ----------------------------------------------------------------------------
// Ce fichier affiche le récapitulatif après avoir terminé le QCM :
// - Score total et pourcentage de réussite
// - Nombre de bonnes et mauvaises réponses
// - Message de félicitations ou encouragement
// - Bouton pour rejouer un nouveau QCM
// - Bouton pour retourner à l'accueil
// - Sauvegarde automatique du résultat dans l'historique
// ============================================================================

import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/storage_service.dart';
import '../services/quiz_stats_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'quiz_intro_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    // Sauvegarder localement
    await StorageService.saveQuizResult(widget.result);

    // Sauvegarder dans Supabase
    await QuizStatsService().saveQuizResult(
      category: widget.result.category,
      totalQuestions: widget.result.totalQuestions,
      correctAnswers: widget.result.correctAnswers,
      score: widget.result.score,
      duration: widget.result.duration,
      answers: widget.result.answers,
    );
  }

  QuizResult get result => widget.result;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildScoreCircle(),
                  const SizedBox(height: 20),
                  _buildResultMessage(context),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  Widget _buildScoreCircle() {
    final percentage = result.percentage;
    final color = percentage >= 70
        ? AppTheme.primaryGreen
        : percentage >= 50
        ? AppTheme.warning
        : AppTheme.incorrect;

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${result.correctAnswers}',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              '/ ${result.totalQuestions}',
              style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultMessage(BuildContext context) {
    final percentage = result.percentage;
    final messages = {
      'Excellente': '🌟 Performance exceptionnelle !',
      'Très bien': '✨ Très bon travail !',
      'Bien': '👍 Bon résultat !',
      'Assez bien': '💪 Continue tes efforts !',
      'À revoir': '📚 Encore un peu de révision...',
    };

    return Column(
      children: [
        Text(
          result.grade,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: percentage >= 70
                ? AppTheme.correct
                : percentage >= 50
                ? AppTheme.warning
                : AppTheme.incorrect,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          messages[result.grade] ?? '',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toStringAsFixed(0)}% de réussite',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle,
              value: '${result.correctAnswers}/${result.totalQuestions}',
              label: 'Correctes',
              color: AppTheme.correct,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              icon: Icons.timer,
              value: _formatDuration(result.duration),
              label: 'Temps',
              color: AppTheme.accentTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.background.withOpacity(0), AppTheme.background],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizIntroScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Rejouer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.surfaceLight),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retour au profil',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
