import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';
import '../data/quiz_data.dart';

class QuizIntroScreen extends StatefulWidget {
  const QuizIntroScreen({super.key});

  @override
  State<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends State<QuizIntroScreen> {
  String? _selectedDifficulty;

  final List<Map<String, dynamic>> _difficulties = [
    {
      'id': 'facile',
      'name': '🟢 Facile',
      'desc': 'Questions de base en chimie',
      'color': Colors.green,
    },
    {
      'id': 'moyen',
      'name': '🟡 Moyen',
      'desc': 'Questions intermédiaires',
      'color': Colors.orange,
    },
    {
      'id': 'difficile',
      'name': '🔴 Difficile',
      'desc': 'Questions avancées',
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Commencer le QCM'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez votre niveau',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez la difficulté du QCM',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            // Options de difficulté
            ..._difficulties.map((diff) => _buildDifficultyOption(diff)),
            const SizedBox(height: 24),
            // Règles du QCM
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Règles du jeu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRule('⏱️ 15 secondes par question'),
                  _buildRule('❌ Timeout = 0 point, pas de réponse affichée'),
                  _buildRule(
                    '🎯 Répondez rapidement pour maximiser vos points',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Bouton commencer
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_selectedDifficulty != null)
                    ? () {
                        final questions = getRandomQuestions(
                          _selectedDifficulty!,
                          count: 10,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              category: categories[0],
                              questions: questions,
                              difficulty: _selectedDifficulty,
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Lancer le QCM',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.surfaceLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }

  Widget _buildDifficultyOption(Map<String, dynamic> diff) {
    final isSelected = _selectedDifficulty == diff['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedDifficulty = diff['id'] as String),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (diff['color'] as Color).withOpacity(0.15)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? (diff['color'] as Color)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diff['name'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      diff['desc'] as String,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
