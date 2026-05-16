import 'package:flutter/material.dart';
import '../models/workout.dart';
import 'create_workout_screen.dart';

class WorkoutTypeSelectionScreen extends StatelessWidget {
  const WorkoutTypeSelectionScreen({super.key});

  static const _types = WorkoutCategory.values;

  static const _icons = [
    Icons.fitness_center,
    Icons.timer,
    Icons.compress,
    Icons.route,
  ];

  static const _colors = [
    Color(0xFF2A9D8F),
    Color(0xFFE9C46A),
    Color(0xFFE76F51),
    Color(0xFF4FC3F7),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B1E),
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text(
          'Create Workout',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const Text(
            'Choose how progress and effort\nare measured for this workout.',
            style: TextStyle(color: Color(0xFF8A9BA8), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          ...List.generate(_types.length, (i) {
            final type = _types[i];
            final color = _colors[i];
            final icon = _icons[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TypeCard(
                type: type,
                icon: icon,
                color: color,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateWorkoutScreen(category: type),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final WorkoutCategory type;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF152126),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: const TextStyle(
                        color: Color(0xFF8A9BA8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: color.withAlpha(180)),
            ],
          ),
        ),
      ),
    );
  }
}
