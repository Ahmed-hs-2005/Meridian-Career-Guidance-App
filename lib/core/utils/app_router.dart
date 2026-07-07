// lib/core/utils/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/area_selection_screen.dart';
import '../../presentation/screens/roadmap/roadmap_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/roadmap/skill_detail_screen.dart';
import '../screens/main_shell.dart';

class AppRouter {
  static GoRouter router(AuthRepository authRepo) {
    return GoRouter(
      initialLocation: '/onboarding',
      redirect: (context, state) {
        final isLoggedIn = authRepo.currentUser != null;
        final isAuthRoute = state.matchedLocation.startsWith('/auth');
        final isOnboarding = state.matchedLocation.startsWith('/onboarding');

        if (!isLoggedIn && !isAuthRoute && !isOnboarding) return '/auth/login';
        if (isLoggedIn && isAuthRoute) return '/home';
        return null;
      },
      refreshListenable: authRepo,
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (ctx, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (ctx, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/register',
          builder: (ctx, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/area-selection',
          builder: (ctx, state) => const AreaSelectionScreen(),
        ),
        ShellRoute(
          builder: (ctx, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (ctx, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/roadmap',
              builder: (ctx, state) => const RoadmapScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (ctx, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/skill/:id',
              builder: (ctx, state) {
                final skillId = state.pathParameters['id']!;
                return SkillDetailScreen(skillId: skillId);
              },
            ),
          ],
        ),
      ],
    );
  }
}
