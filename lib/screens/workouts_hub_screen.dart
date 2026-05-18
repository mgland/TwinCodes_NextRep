import 'package:flutter/material.dart';

import '../data/workout_storage.dart';
import '../models/workout.dart';
import 'create_workout_screen.dart';
import 'doing_workout_screen.dart';
import 'workout_type_selection_screen.dart';

class WorkoutsHubScreen extends StatefulWidget {
  const WorkoutsHubScreen({super.key});

  @override
  State<WorkoutsHubScreen> createState() => _WorkoutsHubScreenState();
}

class _WorkoutsHubScreenState extends State<WorkoutsHubScreen> {
  List<Workout> _workouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    setState(() {
      _workouts = WorkoutStorage.instance.getAllWorkouts();
    });
  }

  Future<void> _goCreateWorkout() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WorkoutTypeSelectionScreen()),
    );
    if (!mounted) return;
    _loadWorkouts();
  }

  Future<void> _goEditWorkout(Workout workout) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateWorkoutScreen(
          category: workout.category,
          initialWorkout: workout,
          editingStorageKey: workout.storageKey,
        ),
      ),
    );
    if (!mounted) return;
    _loadWorkouts();
  }

  Future<void> _goStartWorkout(Workout workout) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoingWorkoutScreen(workout: workout),
      ),
    );
    if (!mounted) return;
    _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadWorkouts(),
      color: const Color(0xFF2A9D8F),
      backgroundColor: const Color(0xFF152126),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Workouts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _goCreateWorkout,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2A9D8F),
                  side: BorderSide(
                    color: const Color(0xFF2A9D8F).withAlpha(160),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${_workouts.length} saved workout${_workouts.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: Color(0xFF8A9BA8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          if (_workouts.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF152126),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E2E33)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No workouts yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create your first workout to see it listed here.',
                    style: TextStyle(
                      color: Color(0xFF8A9BA8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _goCreateWorkout,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._workouts.map(_buildWorkoutCard),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    final exerciseCount = workout.exercises.length;
    final warmupCount = workout.warmups.length;
    final cooldownCount = workout.cooldowns.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF152126),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2E33)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  workout.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _goStartWorkout(workout),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                label: const Text('Start'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2A9D8F),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              TextButton.icon(
                onPressed: () => _goEditWorkout(workout),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2A9D8F),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '${workout.category.shortName}  •  $exerciseCount exercise${exerciseCount == 1 ? '' : 's'}',
            style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '$warmupCount warm-up  •  $cooldownCount cool-down',
            style: const TextStyle(color: Color(0xFF566A72), fontSize: 12),
          ),
          if ((workout.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              workout.note!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
