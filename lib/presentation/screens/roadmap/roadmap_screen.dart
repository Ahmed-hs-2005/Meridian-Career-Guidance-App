// lib/presentation/screens/roadmap/roadmap_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/roadmap_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/roadmap_repository.dart';
import '../../widgets/common/custom_button.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  int _expandedPhase = 0;

  static const _areaColors = {
    'Full-Stack Web': AppColors.webColor,
    'Mobile Apps': AppColors.mobileColor,
    'E-commerce': AppColors.ecomColor,
    'AI API Integration': AppColors.aiColor,
    'SaaS Product': AppColors.saasColor,
  };

  Color _getAreaColor(String area) =>
      _areaColors[area] ?? AppColors.accent;

  @override
  Widget build(BuildContext context) {
    final roadmapRepo = context.watch<RoadmapRepository>();
    final roadmap = roadmapRepo.currentRoadmap;
    final areaColor = roadmap != null ? _getAreaColor(roadmap.area) : AppColors.accent;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CompassRose(size: 18),
            const SizedBox(width: 8),
            const Text('My Roadmap'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/area-selection'),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 18),
            tooltip: 'Change area',
          ),
        ],
      ),
      body: roadmapRepo.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : roadmap == null
              ? _EmptyRoadmap()
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.meridianLine, width: 0.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      AccentBadge(
                                        label: roadmap.area,
                                        color: areaColor,
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${roadmap.phases.length} Phases',
                                        style: TextStyle(color: areaColor, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    roadmap.areaDescription,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.5),
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: roadmap.overallProgress,
                                    backgroundColor: AppColors.primary,
                                    valueColor: AlwaysStoppedAnimation(AppColors.success),
                                    borderRadius: BorderRadius.circular(3),
                                    minHeight: 4,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${roadmap.completedSkills} / ${roadmap.totalSkills} skills — ${(roadmap.overallProgress * 100).round()}% complete',
                                    style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.success),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                            const MeridianDivider(),

                            // Phases
                            ...roadmap.phases.asMap().entries.map((e) {
                              final i = e.key;
                              final phase = e.value;
                              return _PhaseCard(
                                phase: phase,
                                phaseIndex: i,
                                isExpanded: _expandedPhase == i,
                                areaColor: areaColor,
                                roadmapId: roadmap.id,
                                onToggle: () => setState(() {
                                  _expandedPhase = _expandedPhase == i ? -1 : i;
                                }),
                              ).animate(delay: (i * 80).ms).fadeIn().slideY(begin: 0.1, end: 0);
                            }),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final RoadmapPhase phase;
  final int phaseIndex;
  final bool isExpanded;
  final Color areaColor;
  final String roadmapId;
  final VoidCallback onToggle;

  const _PhaseCard({
    required this.phase,
    required this.phaseIndex,
    required this.isExpanded,
    required this.areaColor,
    required this.roadmapId,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completed = phase.skills.where((s) => s.isCompleted).length;
    final total = phase.skills.length;
    final pct = total == 0 ? 0.0 : completed / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpanded ? areaColor.withOpacity(0.3) : AppColors.meridianLine,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Phase header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Phase number circle
                  CircularPercentIndicator(
                    radius: 20,
                    lineWidth: 3,
                    percent: pct,
                    center: Text(
                      '${phaseIndex + 1}',
                      style: TextStyle(
                        color: pct == 1 ? AppColors.success : areaColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    progressColor: pct == 1 ? AppColors.success : areaColor,
                    backgroundColor: AppColors.primary,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(phase.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${phase.estimatedWeeks} weeks · $completed/$total skills',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            Divider(color: AppColors.meridianLine, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phase.description, style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.5)),
                  const SizedBox(height: 16),

                  // Skills
                  Text('Skills', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  ...phase.skills.asMap().entries.map((e) {
                    final si = e.key;
                    final skill = e.value;
                    return _SkillTile(
                      skill: skill,
                      areaColor: areaColor,
                      onToggle: (val) {
                        context.read<RoadmapRepository>().toggleSkill(
                          roadmapId: roadmapId,
                          phaseIndex: phaseIndex,
                          skillIndex: si,
                          isCompleted: val,
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 16),

                  // Mini Projects
                  Text('Mini Projects', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  ...phase.miniProjects.map((proj) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.build_outlined, size: 15, color: areaColor),
                        const SizedBox(width: 10),
                        Text(proj, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),

                  // Courses
                  Text('Recommended Courses', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  ...phase.courses.map((course) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBright,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.meridianLine, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_outline_rounded, size: 18, color: AppColors.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.title, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500)),
                              Text(course.platform, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        AccentBadge(
                          label: course.isFree ? 'Free' : 'Paid',
                          color: course.isFree ? AppColors.success : AppColors.accent,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final dynamic skill;
  final Color areaColor;
  final void Function(bool) onToggle;

  const _SkillTile({required this.skill, required this.areaColor, required this.onToggle});

  static const _levelColors = {
    'beginner': AppColors.success,
    'intermediate': AppColors.accent,
    'advanced': AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final isCompleted = skill.isCompleted as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.accentGreen.withOpacity(0.06) : AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCompleted ? AppColors.accentGreen.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onToggle(!isCompleted),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isCompleted ? AppColors.success : AppColors.textMuted,
                  width: 1.5,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded, size: 12, color: AppColors.primary)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              skill.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          AccentBadge(
            label: skill.level,
            color: _levelColors[skill.level] ?? AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _EmptyRoadmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text('No roadmap generated yet', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Select your development area to generate your AI roadmap', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Pick Your Path',
              onTap: () => context.go('/area-selection'),
              icon: Icons.arrow_forward_rounded,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
