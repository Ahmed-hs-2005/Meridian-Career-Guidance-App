// lib/core/constants/app_constants.dart

class AppConstants {
  static const String appName = 'PathForge';
  static const String appTagline = 'Build Your Dev Career in Pakistan';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String roadmapsCollection = 'roadmaps';
  static const String skillsCollection = 'skills';
  static const String progressCollection = 'progress';
  static const String coursesCollection = 'courses';
  static const String milestonesCollection = 'milestones';

  // Shared Prefs Keys
  static const String kOnboardingDone = 'onboarding_done';
  static const String kSelectedArea = 'selected_area';

  // Anthropic / AI
  static const String claudeModel = 'claude-sonnet-4-20250514';
  static const String anthropicBaseUrl = 'https://api.anthropic.com/v1/messages';

  // Development Areas
  static const List<String> devAreas = [
    'Full-Stack Web',
    'Mobile Apps',
    'E-commerce',
    'AI API Integration',
    'SaaS Product',
  ];
}
