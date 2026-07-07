// lib/data/models/roadmap_model.dart

class RoadmapPhase {
  final int phase;
  final String title;
  final String description;
  final List<SkillItem> skills;
  final List<String> miniProjects;
  final List<CourseItem> courses;
  final int estimatedWeeks;

  const RoadmapPhase({
    required this.phase,
    required this.title,
    required this.description,
    required this.skills,
    required this.miniProjects,
    required this.courses,
    required this.estimatedWeeks,
  });

  factory RoadmapPhase.fromMap(Map<String, dynamic> map) {
    return RoadmapPhase(
      phase: map['phase'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      skills: (map['skills'] as List<dynamic>? ?? [])
          .map((s) => SkillItem.fromMap(s as Map<String, dynamic>))
          .toList(),
      miniProjects: List<String>.from(map['miniProjects'] ?? []),
      courses: (map['courses'] as List<dynamic>? ?? [])
          .map((c) => CourseItem.fromMap(c as Map<String, dynamic>))
          .toList(),
      estimatedWeeks: map['estimatedWeeks'] ?? 2,
    );
  }

  Map<String, dynamic> toMap() => {
        'phase': phase,
        'title': title,
        'description': description,
        'skills': skills.map((s) => s.toMap()).toList(),
        'miniProjects': miniProjects,
        'courses': courses.map((c) => c.toMap()).toList(),
        'estimatedWeeks': estimatedWeeks,
      };
}

class SkillItem {
  final String id;
  final String name;
  final String level; // beginner | intermediate | advanced
  bool isCompleted;

  SkillItem({
    required this.id,
    required this.name,
    required this.level,
    this.isCompleted = false,
  });

  factory SkillItem.fromMap(Map<String, dynamic> map) {
    return SkillItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      level: map['level'] ?? 'beginner',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'level': level,
        'isCompleted': isCompleted,
      };
}

class CourseItem {
  final String title;
  final String platform; // YouTube | Udemy | Coursera | Free
  final String url;
  final bool isFree;

  const CourseItem({
    required this.title,
    required this.platform,
    required this.url,
    required this.isFree,
  });

  factory CourseItem.fromMap(Map<String, dynamic> map) {
    return CourseItem(
      title: map['title'] ?? '',
      platform: map['platform'] ?? '',
      url: map['url'] ?? '',
      isFree: map['isFree'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'platform': platform,
        'url': url,
        'isFree': isFree,
      };
}

class RoadmapModel {
  final String id;
  final String userId;
  final String area;
  final String areaDescription;
  final List<RoadmapPhase> phases;
  final DateTime generatedAt;
  final String nextMilestone;

  const RoadmapModel({
    required this.id,
    required this.userId,
    required this.area,
    required this.areaDescription,
    required this.phases,
    required this.generatedAt,
    required this.nextMilestone,
  });

  int get totalSkills =>
      phases.fold(0, (sum, p) => sum + p.skills.length);

  int get completedSkills =>
      phases.fold(0, (sum, p) => sum + p.skills.where((s) => s.isCompleted).length);

  double get overallProgress =>
      totalSkills == 0 ? 0 : completedSkills / totalSkills;

  factory RoadmapModel.fromMap(Map<String, dynamic> map) {
    return RoadmapModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      area: map['area'] ?? '',
      areaDescription: map['areaDescription'] ?? '',
      phases: (map['phases'] as List<dynamic>? ?? [])
          .map((p) => RoadmapPhase.fromMap(p as Map<String, dynamic>))
          .toList(),
      generatedAt:
          DateTime.tryParse(map['generatedAt'] ?? '') ?? DateTime.now(),
      nextMilestone: map['nextMilestone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'area': area,
        'areaDescription': areaDescription,
        'phases': phases.map((p) => p.toMap()).toList(),
        'generatedAt': generatedAt.toIso8601String(),
        'nextMilestone': nextMilestone,
      };
}
