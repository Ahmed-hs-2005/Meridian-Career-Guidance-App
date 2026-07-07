// lib/data/repositories/roadmap_repository.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/roadmap_model.dart';
import '../../core/constants/app_constants.dart';

class RoadmapRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  RoadmapModel? _currentRoadmap;
  bool _isLoading = false;
  String? _error;

  RoadmapModel? get currentRoadmap => _currentRoadmap;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── Fetch stored roadmap for user ───────────────────────────────────────
  Future<void> fetchRoadmap(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _db
          .collection(AppConstants.roadmapsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        _currentRoadmap = RoadmapModel.fromMap(snap.docs.first.data());
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Generate via Claude AI ───────────────────────────────────────────────
  Future<RoadmapModel?> generateRoadmap({
    required String userId,
    required String area,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prompt = _buildPrompt(area);
      final response = await http.post(
        Uri.parse(AppConstants.anthropicBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': AppConstants.claudeModel,
          'max_tokens': 2000,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;
        final cleaned = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final Map<String, dynamic> roadmapJson = jsonDecode(cleaned);
        final roadmapId = _uuid.v4();
        roadmapJson['id'] = roadmapId;
        roadmapJson['userId'] = userId;
        roadmapJson['generatedAt'] = DateTime.now().toIso8601String();

        final roadmap = RoadmapModel.fromMap(roadmapJson);
        await _saveRoadmap(roadmap);
        _currentRoadmap = roadmap;
        notifyListeners();
        return roadmap;
      } else {
        // Fallback to preset roadmap if API fails
        final roadmap = _getPresetRoadmap(userId, area);
        await _saveRoadmap(roadmap);
        _currentRoadmap = roadmap;
        notifyListeners();
        return roadmap;
      }
    } catch (e) {
      // Fallback to preset
      final roadmap = _getPresetRoadmap(userId, area);
      await _saveRoadmap(roadmap);
      _currentRoadmap = roadmap;
      notifyListeners();
      return roadmap;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _buildPrompt(String area) {
    return '''
You are a career guidance AI for Pakistani tech students. Generate a practical roadmap for "$area" development.

Return ONLY a valid JSON object (no markdown) with this structure:
{
  "area": "$area",
  "areaDescription": "2 sentence description focused on Pakistan market value",
  "nextMilestone": "First specific task to start today",
  "phases": [
    {
      "phase": 1,
      "title": "Phase title",
      "description": "What this phase achieves",
      "estimatedWeeks": 3,
      "skills": [
        {"id": "s1", "name": "Skill name", "level": "beginner", "isCompleted": false}
      ],
      "miniProjects": ["Project 1 name", "Project 2 name"],
      "courses": [
        {"title": "Course name", "platform": "YouTube", "url": "https://youtube.com", "isFree": true}
      ]
    }
  ]
}

Include 5 phases with 3-6 skills each. Focus on freelancing and startup relevance in Pakistan.
''';
  }

  Future<void> _saveRoadmap(RoadmapModel roadmap) async {
    await _db
        .collection(AppConstants.roadmapsCollection)
        .doc(roadmap.id)
        .set(roadmap.toMap());
  }

  // ─── Toggle skill completion ──────────────────────────────────────────────
  Future<void> toggleSkill({
    required String roadmapId,
    required int phaseIndex,
    required int skillIndex,
    required bool isCompleted,
  }) async {
    if (_currentRoadmap == null) return;

    _currentRoadmap!.phases[phaseIndex].skills[skillIndex].isCompleted =
        isCompleted;
    notifyListeners();

    await _db
        .collection(AppConstants.roadmapsCollection)
        .doc(roadmapId)
        .update({'phases': _currentRoadmap!.phases.map((p) => p.toMap()).toList()});
  }

  // ─── Preset fallback roadmaps ─────────────────────────────────────────────
  RoadmapModel _getPresetRoadmap(String userId, String area) {
    final id = _uuid.v4();
    return RoadmapModel(
      id: id,
      userId: userId,
      area: area,
      areaDescription:
          'Master $area development with high-demand skills for Pakistani startups and freelancing markets.',
      generatedAt: DateTime.now(),
      nextMilestone: 'Complete Phase 1 fundamentals this week',
      phases: _getPresetsForArea(area),
    );
  }

  List<RoadmapPhase> _getPresetsForArea(String area) {
    switch (area) {
      case 'Full-Stack Web':
        return _fullStackPhases();
      case 'Mobile Apps':
        return _mobilePhases();
      case 'E-commerce':
        return _ecommercePhases();
      case 'AI API Integration':
        return _aiPhases();
      case 'SaaS Product':
        return _saasPhases();
      default:
        return _fullStackPhases();
    }
  }

  List<RoadmapPhase> _fullStackPhases() => [
        RoadmapPhase(
          phase: 1,
          title: 'Web Fundamentals',
          description: 'Build strong HTML, CSS & JS foundations',
          estimatedWeeks: 3,
          skills: [
            SkillItem(id: 's1', name: 'HTML5 & Semantic Markup', level: 'beginner'),
            SkillItem(id: 's2', name: 'CSS3 & Flexbox/Grid', level: 'beginner'),
            SkillItem(id: 's3', name: 'JavaScript ES6+', level: 'beginner'),
            SkillItem(id: 's4', name: 'Responsive Design', level: 'beginner'),
          ],
          miniProjects: ['Personal Portfolio Site', 'Landing Page Clone'],
          courses: [
            const CourseItem(title: 'HTML & CSS Crash Course', platform: 'YouTube', url: 'https://youtube.com', isFree: true),
            const CourseItem(title: 'JavaScript Basics', platform: 'freeCodeCamp', url: 'https://freecodecamp.org', isFree: true),
          ],
        ),
        RoadmapPhase(
          phase: 2,
          title: 'React & Component Architecture',
          description: 'Build interactive UIs with React',
          estimatedWeeks: 4,
          skills: [
            SkillItem(id: 's5', name: 'React Components & JSX', level: 'intermediate'),
            SkillItem(id: 's6', name: 'Hooks & State Management', level: 'intermediate'),
            SkillItem(id: 's7', name: 'React Router', level: 'intermediate'),
            SkillItem(id: 's8', name: 'REST API Integration', level: 'intermediate'),
          ],
          miniProjects: ['Todo App with Hooks', 'Weather Dashboard'],
          courses: [
            const CourseItem(title: 'React Complete Guide', platform: 'Udemy', url: 'https://udemy.com', isFree: false),
          ],
        ),
        RoadmapPhase(
          phase: 3,
          title: 'Node.js & Firebase Backend',
          description: 'Build and deploy backend services',
          estimatedWeeks: 4,
          skills: [
            SkillItem(id: 's9', name: 'Node.js & Express', level: 'intermediate'),
            SkillItem(id: 's10', name: 'Firebase Auth & Firestore', level: 'intermediate'),
            SkillItem(id: 's11', name: 'REST API Design', level: 'intermediate'),
            SkillItem(id: 's12', name: 'JWT Authentication', level: 'intermediate'),
          ],
          miniProjects: ['CRUD App with Firebase', 'Auth System'],
          courses: [
            const CourseItem(title: 'Node.js Tutorial', platform: 'YouTube', url: 'https://youtube.com', isFree: true),
          ],
        ),
        RoadmapPhase(
          phase: 4,
          title: 'AI API Integration',
          description: 'Add AI features to your apps',
          estimatedWeeks: 3,
          skills: [
            SkillItem(id: 's13', name: 'OpenAI / Gemini API', level: 'advanced'),
            SkillItem(id: 's14', name: 'Prompt Engineering', level: 'advanced'),
            SkillItem(id: 's15', name: 'Firebase Cloud Functions', level: 'advanced'),
          ],
          miniProjects: ['AI Chatbot', 'Smart Form Assistant'],
          courses: [
            const CourseItem(title: 'OpenAI API Basics', platform: 'YouTube', url: 'https://youtube.com', isFree: true),
          ],
        ),
        RoadmapPhase(
          phase: 5,
          title: 'Final SaaS/Product Launch',
          description: 'Ship a real product for Pakistan market',
          estimatedWeeks: 5,
          skills: [
            SkillItem(id: 's16', name: 'Stripe / JazzCash Integration', level: 'advanced'),
            SkillItem(id: 's17', name: 'Firebase Hosting & Deployment', level: 'advanced'),
            SkillItem(id: 's18', name: 'SEO & Performance Optimization', level: 'advanced'),
            SkillItem(id: 's19', name: 'Freelancing Profile Setup', level: 'advanced'),
          ],
          miniProjects: ['Student Portal SaaS', 'Agency Website'],
          courses: [
            const CourseItem(title: 'Firebase Hosting Guide', platform: 'Firebase Docs', url: 'https://firebase.google.com', isFree: true),
          ],
        ),
      ];

  List<RoadmapPhase> _mobilePhases() => [
        RoadmapPhase(
          phase: 1,
          title: 'Dart Language Basics',
          description: 'Master Dart fundamentals for Flutter',
          estimatedWeeks: 2,
          skills: [
            SkillItem(id: 'm1', name: 'Dart Syntax & Types', level: 'beginner'),
            SkillItem(id: 'm2', name: 'OOP in Dart', level: 'beginner'),
            SkillItem(id: 'm3', name: 'Async / Await', level: 'beginner'),
          ],
          miniProjects: ['CLI Calculator', 'Data Class Practice'],
          courses: [
            const CourseItem(title: 'Dart Crash Course', platform: 'YouTube', url: 'https://youtube.com', isFree: true),
          ],
        ),
        RoadmapPhase(
          phase: 2,
          title: 'Flutter UI Development',
          description: 'Build beautiful cross-platform UIs',
          estimatedWeeks: 4,
          skills: [
            SkillItem(id: 'm4', name: 'Flutter Widgets & Layouts', level: 'beginner'),
            SkillItem(id: 'm5', name: 'Navigation & Routing', level: 'intermediate'),
            SkillItem(id: 'm6', name: 'State Management (Provider)', level: 'intermediate'),
          ],
          miniProjects: ['Expense Tracker App', 'Recipe App UI'],
          courses: [
            const CourseItem(title: 'Flutter Complete Course', platform: 'Udemy', url: 'https://udemy.com', isFree: false),
          ],
        ),
        RoadmapPhase(
          phase: 3, title: 'Firebase Integration', description: 'Connect to backend', estimatedWeeks: 3,
          skills: [SkillItem(id: 'm7', name: 'Firebase Auth', level: 'intermediate'), SkillItem(id: 'm8', name: 'Cloud Firestore', level: 'intermediate')],
          miniProjects: ['Login App', 'Real-time Chat'],
          courses: [const CourseItem(title: 'Flutter Firebase', platform: 'YouTube', url: 'https://youtube.com', isFree: true)],
        ),
        RoadmapPhase(
          phase: 4, title: 'REST APIs & Networking', description: 'Integrate external APIs', estimatedWeeks: 2,
          skills: [SkillItem(id: 'm9', name: 'HTTP Package', level: 'intermediate'), SkillItem(id: 'm10', name: 'JSON Parsing', level: 'intermediate')],
          miniProjects: ['News App', 'Weather App'],
          courses: [const CourseItem(title: 'Flutter Networking', platform: 'YouTube', url: 'https://youtube.com', isFree: true)],
        ),
        RoadmapPhase(
          phase: 5, title: 'App Deployment & Freelancing', description: 'Publish and monetize', estimatedWeeks: 3,
          skills: [SkillItem(id: 'm11', name: 'Play Store Publishing', level: 'advanced'), SkillItem(id: 'm12', name: 'App Monetization', level: 'advanced')],
          miniProjects: ['Delivery App Clone', 'Local Business App'],
          courses: [const CourseItem(title: 'Play Store Publishing', platform: 'YouTube', url: 'https://youtube.com', isFree: true)],
        ),
      ];

  List<RoadmapPhase> _ecommercePhases() => [
        RoadmapPhase(phase: 1, title: 'E-commerce Fundamentals', description: 'Understand online selling', estimatedWeeks: 2,
          skills: [SkillItem(id: 'e1', name: 'Shopify Setup', level: 'beginner'), SkillItem(id: 'e2', name: 'Product Management', level: 'beginner')],
          miniProjects: ['Demo Shopify Store'], courses: [const CourseItem(title: 'Shopify Basics', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
        RoadmapPhase(phase: 2, title: 'Custom Storefront', description: 'Build custom React commerce', estimatedWeeks: 4,
          skills: [SkillItem(id: 'e3', name: 'React Commerce UI', level: 'intermediate'), SkillItem(id: 'e4', name: 'Cart & Checkout Logic', level: 'intermediate')],
          miniProjects: ['Online Store Frontend'], courses: [const CourseItem(title: 'React E-commerce', platform: 'Udemy', url: 'https://udemy.com', isFree: false)]),
        RoadmapPhase(phase: 3, title: 'Payment Integration', description: 'Integrate Pakistan payments', estimatedWeeks: 2,
          skills: [SkillItem(id: 'e5', name: 'JazzCash Integration', level: 'intermediate'), SkillItem(id: 'e6', name: 'EasyPaisa API', level: 'intermediate')],
          miniProjects: ['Checkout with JazzCash'], courses: [const CourseItem(title: 'JazzCash Docs', platform: 'Docs', url: 'https://jazzcash.com.pk', isFree: true)]),
        RoadmapPhase(phase: 4, title: 'Admin Panel', description: 'Build seller dashboard', estimatedWeeks: 3,
          skills: [SkillItem(id: 'e7', name: 'Firebase CRUD', level: 'intermediate'), SkillItem(id: 'e8', name: 'Analytics Dashboard', level: 'advanced')],
          miniProjects: ['Admin Panel with Charts'], courses: [const CourseItem(title: 'Firebase Admin', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
        RoadmapPhase(phase: 5, title: 'Launch & Scale', description: 'Launch for Pakistani market', estimatedWeeks: 3,
          skills: [SkillItem(id: 'e9', name: 'SEO for Pakistan', level: 'advanced'), SkillItem(id: 'e10', name: 'Social Selling', level: 'advanced')],
          miniProjects: ['Live Product Store'], courses: [const CourseItem(title: 'E-commerce SEO', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
      ];

  List<RoadmapPhase> _aiPhases() => [
        RoadmapPhase(phase: 1, title: 'AI & API Basics', description: 'Understand LLMs and APIs', estimatedWeeks: 2,
          skills: [SkillItem(id: 'a1', name: 'LLM Concepts', level: 'beginner'), SkillItem(id: 'a2', name: 'REST API Calls', level: 'beginner')],
          miniProjects: ['Hello Claude App'], courses: [const CourseItem(title: 'Intro to LLMs', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
        RoadmapPhase(phase: 2, title: 'Prompt Engineering', description: 'Master prompt design', estimatedWeeks: 3,
          skills: [SkillItem(id: 'a3', name: 'Zero-shot Prompting', level: 'intermediate'), SkillItem(id: 'a4', name: 'Chain of Thought', level: 'intermediate')],
          miniProjects: ['Q&A Bot', 'Content Generator'],
          courses: [const CourseItem(title: 'Prompt Engineering Guide', platform: 'OpenAI Docs', url: 'https://platform.openai.com', isFree: true)]),
        RoadmapPhase(phase: 3, title: 'AI Product Integration', description: 'Build AI-powered apps', estimatedWeeks: 4,
          skills: [SkillItem(id: 'a5', name: 'OpenAI / Gemini SDK', level: 'intermediate'), SkillItem(id: 'a6', name: 'Streaming Responses', level: 'intermediate')],
          miniProjects: ['AI Support Chatbot', 'Resume Analyzer'],
          courses: [const CourseItem(title: 'Build with OpenAI', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
        RoadmapPhase(phase: 4, title: 'Firebase + AI Backend', description: 'Serverless AI functions', estimatedWeeks: 3,
          skills: [SkillItem(id: 'a7', name: 'Cloud Functions', level: 'advanced'), SkillItem(id: 'a8', name: 'Rate Limiting & Caching', level: 'advanced')],
          miniProjects: ['Serverless AI API'], courses: [const CourseItem(title: 'Cloud Functions Guide', platform: 'Firebase Docs', url: 'https://firebase.google.com', isFree: true)]),
        RoadmapPhase(phase: 5, title: 'AI SaaS Launch', description: 'Productize your AI tool', estimatedWeeks: 4,
          skills: [SkillItem(id: 'a9', name: 'Subscription Billing', level: 'advanced'), SkillItem(id: 'a10', name: 'AI Product Marketing', level: 'advanced')],
          miniProjects: ['AI Tool SaaS MVP'], courses: [const CourseItem(title: 'SaaS with Firebase', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
      ];

  List<RoadmapPhase> _saasPhases() => [
        RoadmapPhase(phase: 1, title: 'SaaS Concept & Validation', description: 'Validate your product idea', estimatedWeeks: 2,
          skills: [SkillItem(id: 'ss1', name: 'Problem Validation', level: 'beginner'), SkillItem(id: 'ss2', name: 'MVP Planning', level: 'beginner')],
          miniProjects: ['Market Research Report'],
          courses: [const CourseItem(title: 'SaaS Fundamentals', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
        RoadmapPhase(phase: 2, title: 'Core SaaS Architecture', description: 'Build scalable foundations', estimatedWeeks: 4,
          skills: [SkillItem(id: 'ss3', name: 'Multi-tenant Architecture', level: 'intermediate'), SkillItem(id: 'ss4', name: 'React + Firebase Stack', level: 'intermediate')],
          miniProjects: ['SaaS Boilerplate'],
          courses: [const CourseItem(title: 'SaaS Architecture', platform: 'Udemy', url: 'https://udemy.com', isFree: false)]),
        RoadmapPhase(phase: 3, title: 'Auth & Subscriptions', description: 'User management & billing', estimatedWeeks: 3,
          skills: [SkillItem(id: 'ss5', name: 'Firebase Auth Plans', level: 'intermediate'), SkillItem(id: 'ss6', name: 'Stripe / JazzCash', level: 'intermediate')],
          miniProjects: ['Subscription Flow'],
          courses: [const CourseItem(title: 'Stripe Billing', platform: 'Stripe Docs', url: 'https://stripe.com/docs', isFree: true)]),
        RoadmapPhase(phase: 4, title: 'Analytics & Retention', description: 'Track and grow users', estimatedWeeks: 3,
          skills: [SkillItem(id: 'ss7', name: 'Firebase Analytics', level: 'advanced'), SkillItem(id: 'ss8', name: 'Email Onboarding', level: 'advanced')],
          miniProjects: ['Analytics Dashboard'],
          courses: [const CourseItem(title: 'Product Analytics', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
        RoadmapPhase(phase: 5, title: 'Go-to-Market Pakistan', description: 'Launch and acquire customers', estimatedWeeks: 4,
          skills: [SkillItem(id: 'ss9', name: 'LinkedIn & Social Marketing', level: 'advanced'), SkillItem(id: 'ss10', name: 'Upwork Listing', level: 'advanced')],
          miniProjects: ['Public SaaS Launch'],
          courses: [const CourseItem(title: 'SaaS Marketing Pakistan', platform: 'YouTube', url: 'https://youtube.com', isFree: true)]),
      ];
}
