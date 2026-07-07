// lib/data/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String selectedArea;
  final DateTime createdAt;
  final int totalSkills;
  final int completedSkills;
  final int totalProjects;
  final int completedProjects;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.selectedArea,
    required this.createdAt,
    this.totalSkills = 0,
    this.completedSkills = 0,
    this.totalProjects = 0,
    this.completedProjects = 0,
  });

  double get progressPercent =>
      totalSkills == 0 ? 0 : completedSkills / totalSkills;

  int get pendingSkills => totalSkills - completedSkills;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      selectedArea: map['selectedArea'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      totalSkills: map['totalSkills'] ?? 0,
      completedSkills: map['completedSkills'] ?? 0,
      totalProjects: map['totalProjects'] ?? 0,
      completedProjects: map['completedProjects'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'selectedArea': selectedArea,
        'createdAt': createdAt.toIso8601String(),
        'totalSkills': totalSkills,
        'completedSkills': completedSkills,
        'totalProjects': totalProjects,
        'completedProjects': completedProjects,
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? selectedArea,
    int? totalSkills,
    int? completedSkills,
    int? totalProjects,
    int? completedProjects,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      selectedArea: selectedArea ?? this.selectedArea,
      createdAt: createdAt,
      totalSkills: totalSkills ?? this.totalSkills,
      completedSkills: completedSkills ?? this.completedSkills,
      totalProjects: totalProjects ?? this.totalProjects,
      completedProjects: completedProjects ?? this.completedProjects,
    );
  }
}
