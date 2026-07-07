// lib/presentation/screens/onboarding/area_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/roadmap_repository.dart';
import '../../widgets/common/custom_button.dart';

class _AreaOption {
  final String label;
  final String icon;
  final String desc;
  final Color color;
  final String marketNote;

  const _AreaOption({
    required this.label,
    required this.icon,
    required this.desc,
    required this.color,
    required this.marketNote,
  });
}

const _areas = [
  _AreaOption(label: 'Full-Stack Web', icon: '🌐', desc: 'React · Node.js · Firebase', color: AppColors.webColor, marketNote: '95% market demand'),
  _AreaOption(label: 'Mobile Apps', icon: '📱', desc: 'Flutter · Firebase · REST', color: AppColors.mobileColor, marketNote: '90% market demand'),
  _AreaOption(label: 'E-commerce', icon: '🛒', desc: 'Shopify · WooCommerce · React', color: AppColors.ecomColor, marketNote: '88% market demand'),
  _AreaOption(label: 'AI API Integration', icon: '🤖', desc: 'OpenAI · Gemini · Firebase Fn', color: AppColors.aiColor, marketNote: '85% market demand'),
  _AreaOption(label: 'SaaS Product', icon: '💡', desc: 'React · Firebase · Stripe', color: AppColors.saasColor, marketNote: '82% market demand'),
];

class AreaSelectionScreen extends StatefulWidget {
  const AreaSelectionScreen({super.key});

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  String? _selected;
  bool _generating = false;

  Future<void> _generate() async {
    if (_selected == null) return;
    setState(() => _generating = true);

    final authRepo = context.read<AuthRepository>();
    final roadmapRepo = context.read<RoadmapRepository>();
    final uid = authRepo.currentUser!.uid;

    await roadmapRepo.generateRoadmap(userId: uid, area: _selected!);

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Choose Your Path', style: Theme.of(context).textTheme.displayMedium)
                  .animate().fadeIn().slideY(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Pick the development area most relevant to your goals in Pakistan\'s tech market.',
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: _areas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final area = _areas[i];
                    final isSelected = _selected == area.label;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = area.label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? area.color.withOpacity(0.12)
                              : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? area.color : AppColors.meridianLine,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: area.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(area.icon, style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    area.label,
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                          color: isSelected ? area.color : AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(area.desc, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  area.marketNote,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: area.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? area.color : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? area.color : AppColors.textMuted,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, size: 12, color: AppColors.primary)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (i * 80).ms).fadeIn().slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _generating ? 'Generating Roadmap...' : 'Generate My Roadmap',
                isLoading: _generating,
                icon: Icons.auto_awesome_rounded,
                onTap: _selected == null ? null : _generate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
