// lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/roadmap_repository.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final roadmap = context.watch<RoadmapRepository>().currentRoadmap;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CompassRose(size: 18),
            const SizedBox(width: 8),
            const Text('Profile'),
          ],
        ),
      ),
      body: FutureBuilder<UserModel?>(
        future: auth.currentUser != null
            ? auth.getUserProfile(auth.currentUser!.uid)
            : Future.value(null),
        builder: (ctx, snap) {
          final user = snap.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.meridianLine, width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.7, 0.7)),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Loading...',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 8),
                if (user?.selectedArea.isNotEmpty == true)
                  AccentBadge(label: user!.selectedArea)
                      .animate().fadeIn(delay: 200.ms),
                const MeridianDivider(),

                // Stats
                if (roadmap != null) ...[
                  Row(
                    children: [
                      _StatCard(value: '${roadmap.completedSkills}', label: 'Skills Done', color: AppColors.success),
                      const SizedBox(width: 12),
                      _StatCard(value: '${roadmap.totalSkills}', label: 'Total Skills', color: AppColors.accent),
                      const SizedBox(width: 12),
                      _StatCard(value: '${roadmap.phases.length}', label: 'Phases', color: AppColors.warning),
                    ],
                  ).animate().fadeIn(delay: 250.ms),
                  const MeridianDivider(),
                ],

                // Menu items
                _MenuTile(
                  icon: Icons.route_rounded,
                  label: 'My Roadmap',
                  onTap: () => context.go('/roadmap'),
                ).animate().fadeIn(delay: 300.ms),
                _MenuTile(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Change Career Area',
                  onTap: () => context.go('/area-selection'),
                ).animate().fadeIn(delay: 350.ms),
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {},
                ).animate().fadeIn(delay: 400.ms),
                _MenuTile(
                  icon: Icons.info_outline_rounded,
                  label: 'About Meridian',
                  onTap: () => _showAbout(context),
                ).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 12),
                _MenuTile(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  color: AppColors.error,
                  onTap: () async {
                    await context.read<AuthRepository>().signOut();
                  },
                ).animate().fadeIn(delay: 500.ms),
                const MeridianDivider(),
                Text(
                  'Meridian v1.0.0 · Your intelligent guide to mastering development careers',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 550.ms),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('About Meridian', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Meridian is your intelligent guide to mastering development careers. It provides personalized learning roadmaps powered by AI, helping you chart the exact path from beginner to industry-ready.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.meridianLine, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 18),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500, fontSize: 14)),
            const Spacer(),
            if (color == null)
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
