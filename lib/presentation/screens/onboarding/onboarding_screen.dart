// lib/presentation/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/custom_button.dart';

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

const _pages = [
  _OnboardPage(
    emoji: '🧭',
    title: 'Navigate Your\nCareer Path',
    subtitle: 'Your intelligent guide to mastering development careers — charting the exact path from beginner to industry-ready.',
    accent: AppColors.accent,
  ),
  _OnboardPage(
    emoji: '⭐',
    title: 'Personalized\nRoadmaps',
    subtitle: 'Pick your development area and get a step-by-step path with real projects and milestones.',
    accent: AppColors.accent,
  ),
  _OnboardPage(
    emoji: '�',
    title: 'Track Your\nProgress',
    subtitle: 'Mark skills complete, watch your progress grow, and hit milestones that employers notice.',
    accent: AppColors.accent,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background mesh
          Positioned.fill(
            child: CustomPaint(painter: _MeshPainter(_currentPage)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header with branding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CompassRose(size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Meridian',
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: AppColors.accent,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/auth/login'),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (ctx, i) => _PageContent(page: _pages[i]),
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: WormEffect(
                          dotColor: AppColors.textMuted,
                          activeDotColor: AppColors.accent,
                          dotHeight: 6,
                          dotWidth: 6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        icon: _currentPage == _pages.length - 1
                            ? Icons.arrow_forward_rounded
                            : null,
                        onTap: () {
                          if (_currentPage == _pages.length - 1) {
                            context.go('/auth/register');
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.go('/auth/login'),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 0.5),
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 32)),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppColors.textPrimary,
                ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

// Subtle background mesh painter
class _MeshPainter extends CustomPainter {
  final int page;
  _MeshPainter(this.page);

  static const colors = [AppColors.accent, AppColors.accentWarm, AppColors.accentGreen];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.meridianLine
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.6, 0)
      ..quadraticBezierTo(size.width, size.height * 0.3, size.width, 0)
      ..close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = AppColors.meridianLine
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.4, size.height, 0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) => oldDelegate.page != page;
}
