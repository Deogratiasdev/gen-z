import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

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
      appBar: AppBar(title: const Text('Détail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.percentage >= 70
                    ? AppTheme.correct
                    : item.percentage >= 50
                    ? AppTheme.warning
                    : AppTheme.incorrect,
              ),
              child: Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surface,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${item.score}',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        'points',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              item.grade,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: item.percentage >= 70
                    ? AppTheme.correct
                    : item.percentage >= 50
                    ? AppTheme.warning
                    : AppTheme.incorrect,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(item.date),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  _buildRow('Catégorie', item.category, AppTheme.accentPrimary),
                  const Divider(color: AppTheme.surfaceLight, height: 24),
                  _buildRow(
                    'Correctes',
                    '${item.correctAnswers}/${item.totalQuestions}',
                    AppTheme.correct,
                  ),
                  const Divider(color: AppTheme.surfaceLight, height: 24),
                  _buildRow(
                    'Pourcentage',
                    '${item.percentage.toInt()}%',
                    AppTheme.accentTertiary,
                  ),
                  const Divider(color: AppTheme.surfaceLight, height: 24),
                  _buildRow(
                    'Durée',
                    _formatDuration(item.duration),
                    AppTheme.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
