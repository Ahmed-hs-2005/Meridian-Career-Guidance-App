// lib/presentation/screens/dashboard/dashboard_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/roadmap_repository.dart';
import '../../widgets/common/custom_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthRepository>();
      if (auth.currentUser != null) {
        context.read<RoadmapRepository>().fetchRoadmap(auth.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roadmapRepo = context.watch<RoadmapRepository>();
    final roadmap = roadmapRepo.currentRoadmap;
    final auth = context.watch<AuthRepository>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CompassRose(size: 20),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meridian',
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: AppColors.accent,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.meridianLine, width: 0.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: AppColors.textSecondary, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  FutureBuilder(
                    future: auth.currentUser != null
                        ? auth.getUserProfile(auth.currentUser!.uid)
                        : Future.value(null),
                    builder: (ctx, snap) {
                      final name = snap.data?.name ?? 'Developer';
                      return Text(
                        'Welcome, ${name.split(' ').first}',
                        style: Theme.of(context).textTheme.displayMedium,
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0);
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roadmap != null ? roadmap.area : 'Loading your roadmap...',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.accent),
                  ).animate().fadeIn(delay: 100.ms),
                  const MeridianDivider(),

                  // Progress Ring + Stats Row
                  if (roadmap != null) ...[
                    _ProgressCard(roadmap: roadmap),
                    const SizedBox(height: 16),
                    _StatsRow(roadmap: roadmap),
                    const MeridianDivider(),

                    // Phase Progress Chart
                    _PhaseChart(roadmap: roadmap),
                    const MeridianDivider(),

                    // Next Milestone
                    _MilestoneCard(milestone: roadmap.nextMilestone),
                    const MeridianDivider(),

                    // Phase list preview
                    Text('Phases Overview', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    ...roadmap.phases.asMap().entries.map((e) {
                      final i = e.key;
                      final phase = e.value;
                      final completed = phase.skills.where((s) => s.isCompleted).length;
                      final total = phase.skills.length;
                      final pct = total == 0 ? 0.0 : completed / total;
                      return GlassCard(
                        onTap: () => context.go('/roadmap'),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: pct == 1
                                    ? AppColors.success.withOpacity(0.15)
                                    : AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: pct == 1 ? AppColors.success : AppColors.accent,
                                  width: 0.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: pct == 1 ? AppColors.success : AppColors.accent,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(phase.title, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: AppColors.primary,
                                    valueColor: AlwaysStoppedAnimation(
                                      pct == 1 ? AppColors.success : AppColors.accent,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                    minHeight: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$completed/$total',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ).animate(delay: (i * 80).ms).fadeIn().slideX(begin: 0.1, end: 0);
                    }),
                  ] else if (roadmapRepo.isLoading) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                      ),
                    ),
                  ] else ...[
                    GlassCard(
                      child: Column(
                        children: [
                          const CompassRose(size: 48),
                          const SizedBox(height: 16),
                          Text('No roadmap yet', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text('Pick your development area to get started', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            label: 'Choose Area',
                            onTap: () => context.go('/area-selection'),
                            icon: Icons.arrow_forward_rounded,
                            width: 200,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final dynamic roadmap;
  const _ProgressCard({required this.roadmap});

  @override
  Widget build(BuildContext context) {
    final pct = roadmap.overallProgress as double;
    return GlassCard(
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 48,
            lineWidth: 6,
            percent: pct,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(pct * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text('complete', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            progressColor: AppColors.success,
            backgroundColor: AppColors.primary,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roadmap.area,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  '${roadmap.completedSkills} of ${roadmap.totalSkills} skills completed',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                AccentBadge(
                  label: pct == 0
                      ? 'Just started'
                      : pct < 0.5
                          ? 'In progress'
                          : pct < 1
                              ? 'Almost there'
                              : 'Completed',
                  color: pct >= 1 ? AppColors.success : AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic roadmap;
  const _StatsRow({required this.roadmap});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Skills Done', 'value': '${roadmap.completedSkills}', 'color': AppColors.success},
      {'label': 'Total Skills', 'value': '${roadmap.totalSkills}', 'color': AppColors.accent},
      {'label': 'Pending', 'value': '${roadmap.totalSkills - roadmap.completedSkills}', 'color': AppColors.warning},
    ];
    return Row(
      children: stats.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: (s['color'] as Color).withOpacity(0.3), width: 0.5),
            ),
            child: Column(
              children: [
                Text(
                  s['value'] as String,
                  style: TextStyle(
                    color: s['color'] as Color,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(s['label'] as String, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ).animate(delay: (i * 80).ms).fadeIn().slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }
}

class _PhaseChart extends StatelessWidget {
  final dynamic roadmap;
  const _PhaseChart({required this.roadmap});

  @override
  Widget build(BuildContext context) {
    final phases = roadmap.phases as List;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phase Progress', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1,
                barGroups: phases.asMap().entries.map((e) {
                  final phase = e.value;
                  final completed = (phase.skills as List).where((s) => s.isCompleted).length;
                  final total = (phase.skills as List).length;
                  final pct = total == 0 ? 0.0 : completed / total;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: pct == 0 ? 0.04 : pct,
                        color: pct == 1
                            ? AppColors.success
                            : pct > 0.5
                                ? AppColors.accent
                                : AppColors.warning,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        return Text(
                          'P${val.toInt() + 1}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.meridianLine, strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _MilestoneCard extends StatelessWidget {
  final String milestone;
  const _MilestoneCard({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(child: Icon(Icons.flag_rounded, color: AppColors.accent, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Milestone',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }
}
