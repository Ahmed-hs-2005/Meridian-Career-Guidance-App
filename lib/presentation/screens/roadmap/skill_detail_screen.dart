// lib/presentation/screens/roadmap/skill_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SkillDetailScreen extends StatelessWidget {
  final String skillId;
  const SkillDetailScreen({super.key, required this.skillId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Detail')),
      body: Center(
        child: Text('Skill: $skillId', style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
