import 'package:flutter/material.dart';

import '../models/workout.dart';

class DoingWorkoutScreen extends StatelessWidget {
  final Workout workout;

  const DoingWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B1E),
        title: Text(
          workout.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF152126),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E2E33)),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_circle_fill_rounded,
                    color: Color(0xFF2A9D8F), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${workout.exercises.length} exercise${workout.exercises.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 13),
                  ),
                ),
                Text(
                  workout.category.shortName,
                  style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...workout.exercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final exercise = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF152126),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E2E33)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A9D8F).withAlpha(42),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          color: Color(0xFF2A9D8F),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exercise.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${exercise.sets.length} set${exercise.sets.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Color(0xFF8A9BA8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
