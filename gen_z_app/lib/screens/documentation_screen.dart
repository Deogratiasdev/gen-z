import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Documentation Soutenance'),
        backgroundColor: AppTheme.accentPrimary.withOpacity(0.2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentPrimary.withOpacity(0.3),
                    AppTheme.accentPrimary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentPrimary.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.school,
                    size: 48,
                    color: AppTheme.accentPrimary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Guide de Soutenance',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tout ce qu\'il faut savoir pour présenter Gen Z Quiz',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créé par Andy CHADARE - 2026',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sections
            _buildSection(
              context,
              '1. Présentation du Projet',
              'Gen Z Quiz est une application mobile de QCM (Questions à Choix Multiples) moderne et épurée, destinée aux étudiants pour réviser différentes matières scientifiques.',
              [
                'Interface sombre élégante (style Gen Z)',
                '4 catégories : Chimie, Maths, Physique, Biologie',
                '34 questions avec explications détaillées',
                'Système de scoring et historique',
              ],
            ),

            _buildSection(
              context,
              '2. Architecture Technique',
              'L\'application est développée en Flutter (Dart) avec une architecture propre et modulaire.',
              [
                'lib/models/ : Classes Question, Category, QuizResult',
                'lib/screens/ : Toutes les pages de l\'app',
                'lib/services/ : Stockage local (SharedPreferences)',
                'lib/theme/ : Design system et couleurs',
                'lib/widgets/ : Composants réutilisables',
              ],
            ),

            _buildSection(
              context,
              '3. Fonctionnalités Clés',
              'Ce qui rend l\'app unique et moderne.',
              [
                '✨ Feedback immédiat avec explications multiples (random)',
                '🎯 Animation texte style IA (typewriter effect)',
                '📊 Historique complet avec recherche',
                '🎨 Personnalisation du thème (4 couleurs)',
                '💾 Persistence des données locale',
              ],
            ),

            _buildSection(
              context,
              '4. Flux Utilisateur',
              'Parcours typique d\'un utilisateur.',
              [
                '1. Page d\'accueil avec animation titre',
                '2. Choix de la catégorie (4 options)',
                '3. QCM successif avec feedback après chaque réponse',
                '4. Résultats détaillés avec stats',
                '5. Accès historique pour réviser',
              ],
            ),

            _buildSection(
              context,
              '5. Points Techniques à Souligner',
              'Aspects techniques impressionnants pour le jury.',
              [
                'Stockage local avec SharedPreferences',
                'Gestion d\'état sans framework externe (setState)',
                'Animations fluides (AnimatedContainer, FadeTransition)',
                'Système de thème dynamique',
                'Navigation avec MaterialPageRoute',
              ],
            ),

            _buildSection(
              context,
              '6. Améliorations Futures',
              'Ce qui pourrait être ajouté plus tard.',
              [
                'Mode multijoueur en temps réel',
                'Plus de catégories (Histoire, Géographie...)',
                'Synchronisation cloud',
                'Mode sombre/clair automatique',
                'Partage des scores sur réseaux sociaux',
              ],
            ),

            const SizedBox(height: 32),

            // Footer encouragement
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.correct.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.correct.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 40,
                    color: AppTheme.correct,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bonne chance pour ta soutenance !',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.correct,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu as fait un excellent travail avec cette app. Andy est fier de toi ! 💪',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<String> points,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.accentPrimary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppTheme.accentPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
