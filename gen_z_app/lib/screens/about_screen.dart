import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'À propos de l\'app',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo et titre
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surface,
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/launcher_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gen Z Quiz',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chimie Organique',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Section Description
            _buildSection(
              context,
              '🎯 Objectif',
              'Cette application est conçue pour les exposés et présentations sur la chimie organique. Elle permet de tester vos connaissances de manière interactive et engaging.',
              Icons.track_changes,
            ),

            // Section Authentification
            _buildSection(
              context,
              '🔐 Authentification',
              'L\'app utilise Supabase pour l\'authentification sécurisée :\n\n'
                  '• Connexion/Inscription par email\n'
                  '• Profil utilisateur personnalisable\n'
                  '• Sauvegarde automatique des progrès\n'
                  '• Synchronisation multi-appareils',
              Icons.lock_outline,
            ),

            // Section QCM
            _buildSection(
              context,
              '📚 Système QCM',
              'Les quiz sont organisés en :\n\n'
                  '• 3 niveaux de difficulté\n'
                  '• 10 questions par quiz\n'
                  '• Timer de 15 secondes par question\n'
                  '• Explications détaillées après chaque réponse\n'
                  '• Historique complet des résultats',
              Icons.quiz_outlined,
            ),

            // Section Architecture
            _buildSection(
              context,
              '🏗️ Architecture Technique',
              'Structure de l\'application :\n\n'
                  '• **lib/main.dart** : Point d\'entrée et configuration\n'
                  '• **lib/screens/** : Pages de l\'interface\n'
                  '• **lib/services/** : Logique métier (Supabase, stockage)\n'
                  '• **lib/models/** : Modèles de données\n'
                  '• **lib/theme/** : Thème et styles\n'
                  '• **lib/widgets/** : Composants réutilisables',
              Icons.code_outlined,
            ),

            // Section Technologies
            _buildSection(
              context,
              '⚙️ Technologies',
              'Stack technique utilisé :\n\n'
                  '• **Flutter** : Framework cross-platform\n'
                  '• **Supabase** : Backend BaaS (Base de données + Auth)\n'
                  '• **Dart** : Langage de programmation\n'
                  '• **Google Fonts** : Typographie moderne',
              Icons.devices_outlined,
            ),

            // Section Utilisation
            _buildSection(
              context,
              '📖 Comment utiliser',
              '1. Créez votre compte ou connectez-vous\n'
                  '2. Complétez votre profil\n'
                  '3. Choisissez un niveau de difficulté\n'
                  '4. Répondez aux questions dans le temps imparti\n'
                  '5. Consultez vos résultats et historique\n'
                  '6. Répétez pour améliorer vos scores !',
              Icons.play_circle_outline,
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Créé par Hilary KPANOU & Andy CHADARE',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© ${DateTime.now().year} - Version 1.0.0',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
