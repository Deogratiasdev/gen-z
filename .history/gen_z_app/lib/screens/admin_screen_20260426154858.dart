// ============================================================================
// ÉCRAN D'ADMINISTRATION
// ----------------------------------------------------------------------------
// Ce fichier gère l'interface administrateur (réservée aux admins) :
// - Liste de tous les utilisateurs inscrits
// - Statistiques globales de l'application
// - Gestion des droits administrateur
// - Vue d'ensemble des performances
// - Accès restreint par vérification des privilèges
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/admin_service.dart';
import '../services/supabase_service.dart';
import 'auth_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _globalStats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoad();
  }

  Future<void> _checkAdminAndLoad() async {
    if (!AdminService().isCurrentUserAdmin) {
      setState(() {
        _error = 'Accès refusé : Vous devez être administrateur';
        _isLoading = false;
      });
      return;
    }
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await AdminService().getAllUsers();
      final stats = await AdminService().getGlobalStats();
      if (mounted) {
        setState(() {
          _users = users;
          _globalStats = stats;
          _isLoading = false;
        });
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Pas de connexion internet. Vérifiez votre réseau.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur: ${e.toString().replaceAll('Exception: ', '')}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUser(String userId, String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Confirmer la suppression',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer $email ?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppTheme.incorrect),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService().deleteUser(userId);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utilisateur supprimé'),
              backgroundColor: AppTheme.correct,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppTheme.incorrect,
            ),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    await SupabaseService().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Administration'),
        actions: [
          // Menu regroupé
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onSelected: (value) {
              if (value == 'refresh') _loadData();
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                enabled: !_isLoading,
                child: Row(
                  children: [
                    _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    const Text('Actualiser'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _error!.contains('internet') ||
                              _error!.contains('connexion')
                          ? Icons.wifi_off
                          : Icons.error_outline,
                      color: AppTheme.incorrect,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.incorrect,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Retour'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            foregroundColor: AppTheme.textPrimary,
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primaryGreen,
              backgroundColor: AppTheme.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats globales
                    if (_globalStats != null) ...[
                      _buildSectionTitle('Statistiques globales'),
                      _buildGlobalStats(),
                      const SizedBox(height: 24),
                    ],
                    // Liste des utilisateurs
                    _buildSectionTitle('Liste des utilisateurs'),
                    _buildUsersList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGlobalStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Utilisateurs',
          '${_globalStats?['total_users'] ?? 0}',
          Icons.people,
          AppTheme.primaryGreen,
        ),
        _buildStatCard(
          'QCM réalisés',
          '${_globalStats?['total_quizzes'] ?? 0}',
          Icons.quiz,
          AppTheme.correct,
        ),
        _buildStatCard(
          'Score moyen',
          '${(_globalStats?['average_score_global'] ?? 0).toStringAsFixed(1)}%',
          Icons.trending_up,
          AppTheme.warning,
        ),
        _buildStatCard(
          'Meilleur score',
          '${(_globalStats?['best_user_score'] ?? 0).toStringAsFixed(1)}%',
          Icons.emoji_events,
          AppTheme.accentSecondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Aucun utilisateur',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = _users[index];
        final isAdmin = user['is_admin'] == true;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isAdmin
                ? Border.all(color: AppTheme.primaryGreen, width: 2)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isAdmin
                  ? AppTheme.primaryGreen
                  : AppTheme.surfaceLight,
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: isAdmin ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            title: Text(
              user['email'] ?? 'Sans email',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Inscrit le: ${_formatDate(user['created_at'])}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                if (user['last_sign_in_at'] != null)
                  Text(
                    'Dernière connexion: ${_formatDate(user['last_sign_in_at'])}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                if (isAdmin)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: !isAdmin
                ? IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.incorrect,
                    ),
                    onPressed: () => _deleteUser(user['id'], user['email']),
                  )
                : null,
          ),
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Jamais';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Invalide';
    }
  }
}
