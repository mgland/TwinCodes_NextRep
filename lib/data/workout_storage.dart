import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../models/equipment.dart';
import '../models/exercise.dart';
import '../models/warmup_cooldown.dart';
import '../models/workout.dart';

class WorkoutStorage {
  WorkoutStorage._();

  static final WorkoutStorage instance = WorkoutStorage._();

  static String get _boxName => '${AppConstants.hiveId}-workouts';
  static String get _activeSessionBoxName => '${AppConstants.hiveId}-active-workout';
  static const String _activeSessionKey = 'current';

  Box<dynamic>? _box;
  Box<dynamic>? _activeSessionBox;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
    } on MissingPluginException {
      // Fallback for environments where path_provider is unavailable/not registered.
      final dir = Directory('${Directory.systemTemp.path}/${AppConstants.appIdentifier}');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      Hive.init(dir.path);
    }
    _box ??= await Hive.openBox<dynamic>(_boxName);
    _activeSessionBox ??= await Hive.openBox<dynamic>(_activeSessionBoxName);
  }

  Future<void> saveWorkout(Workout workout) async {
    final box = await _ensureBox();
    if (workout.storageKey != null && box.containsKey(workout.storageKey)) {
      await box.put(workout.storageKey, _workoutToMap(workout));
      return;
    }

    final key = await box.add(_workoutToMap(workout));
    workout.storageKey = key;
  }

  List<Workout> getAllWorkouts() {
    if (_box == null) return [];

    return _box!.toMap().entries
        .where((entry) => entry.value is Map)
        .map((entry) => _workoutFromMap(
              Map<String, dynamic>.from(entry.value as Map),
              storageKey: entry.key is int ? entry.key as int : null,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Box<dynamic>> _ensureBox() async {
    if (_box != null) return _box!;
    await init();
    return _box!;
  }

  Future<Box<dynamic>> _ensureActiveSessionBox() async {
    if (_activeSessionBox != null) return _activeSessionBox!;
    await init();
    return _activeSessionBox!;
  }

  Future<void> saveActiveWorkoutSession(ActiveWorkoutSession session) async {
    final box = await _ensureActiveSessionBox();
    await box.put(_activeSessionKey, _activeWorkoutSessionToMap(session));
  }

  ActiveWorkoutSession? getActiveWorkoutSession() {
    final raw = _activeSessionBox?.get(_activeSessionKey);
    if (raw is! Map) return null;
    return _activeWorkoutSessionFromMap(Map<String, dynamic>.from(raw));
  }

  Future<void> clearActiveWorkoutSession() async {
    final box = await _ensureActiveSessionBox();
    await box.delete(_activeSessionKey);
  }

  Map<String, dynamic> _workoutToMap(Workout w) {
    return {
      'name': w.name,
      'category': w.category.index,
      'note': w.note,
      'createdAt': w.createdAt.toIso8601String(),
      'warmups': w.warmups.map(_warmupToMap).toList(),
      'cooldowns': w.cooldowns.map(_warmupToMap).toList(),
      'exercises': w.exercises.map(_entryToMap).toList(),
    };
  }

  Map<String, dynamic> _activeWorkoutSessionToMap(ActiveWorkoutSession session) {
    return {
      'workout': _workoutToMap(session.workout),
      'elapsedSeconds': session.elapsedSeconds,
      'restSecondsRemaining': session.restSecondsRemaining,
      'restingItemIndex': session.restingItemIndex,
      'activeIndex': session.activeIndex,
      'updatedAt': session.updatedAt.toIso8601String(),
      'items': session.items.map(_activeWorkoutItemStateToMap).toList(),
    };
  }

  Map<String, dynamic> _entryToMap(WorkoutExerciseEntry e) {
    return {
      'exercise': {
        'id': e.exercise.id,
        'name': e.exercise.name,
        'primaryMuscle': e.exercise.primaryMuscle.index,
      },
      'equipment': e.equipment.map((eq) => {
            'id': eq.id,
            'name': eq.name,
            'category': eq.category.index,
          }).toList(),
      'sets': e.sets.map(_setToMap).toList(),
      'note': e.note,
      'exerciseDurationSeconds': e.exerciseDurationSeconds,
      'restAfterExerciseSeconds': e.restAfterExerciseSeconds,
    };
  }

  Map<String, dynamic> _setToMap(WorkoutSet s) {
    return {
      'reps': s.reps,
      'weightKg': s.weightKg,
      'durationSeconds': s.durationSeconds,
      'tempoEccentric': s.tempoEccentric,
      'tempoPause1': s.tempoPause1,
      'tempoConcentric': s.tempoConcentric,
      'tempoPause2': s.tempoPause2,
      'distanceKm': s.distanceKm,
      'calories': s.calories,
      'rpe': s.rpe,
      'restSeconds': s.restSeconds,
      'note': s.note,
    };
  }

  Map<String, dynamic> _warmupToMap(WarmupCooldownItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'type': item.type.index,
      'category': item.category.index,
    };
  }

  Map<String, dynamic> _activeWorkoutItemStateToMap(ActiveWorkoutItemState item) {
    return {
      'goalReps': item.goalReps,
      'reps': item.reps,
      'done': item.done,
    };
  }

  Workout _workoutFromMap(Map<String, dynamic> m, {int? storageKey}) {
    final categoryIndex = _asInt(m['category']) ?? 0;
    final createdAtRaw = m['createdAt'] as String?;
    final createdAt = createdAtRaw == null
        ? DateTime.now()
        : DateTime.tryParse(createdAtRaw) ?? DateTime.now();

    final exercises = _asList(m['exercises'])
        .map((e) => _entryFromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final warmups = _asList(m['warmups'])
        .map((e) => _warmupFromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final cooldowns = _asList(m['cooldowns'])
        .map((e) => _warmupFromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Workout(
      storageKey: storageKey,
      name: m['name'] as String? ?? 'Workout',
      category: WorkoutCategory.values[_clampIndex(categoryIndex, WorkoutCategory.values.length)],
      exercises: exercises,
      warmups: warmups,
      cooldowns: cooldowns,
      note: m['note'] as String?,
      createdAt: createdAt,
    );
  }

  ActiveWorkoutSession _activeWorkoutSessionFromMap(Map<String, dynamic> m) {
    final workoutMap = Map<String, dynamic>.from((m['workout'] ?? const {}) as Map);
    final updatedAtRaw = m['updatedAt'] as String?;
    return ActiveWorkoutSession(
      workout: _workoutFromMap(workoutMap),
      elapsedSeconds: _asInt(m['elapsedSeconds']) ?? 0,
      restSecondsRemaining: _asInt(m['restSecondsRemaining']) ?? 0,
      restingItemIndex: _asInt(m['restingItemIndex']),
      activeIndex: _asInt(m['activeIndex']),
      updatedAt: updatedAtRaw == null
          ? DateTime.now()
          : DateTime.tryParse(updatedAtRaw) ?? DateTime.now(),
      items: _asList(m['items'])
          .map((item) => _activeWorkoutItemStateFromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  WorkoutExerciseEntry _entryFromMap(Map<String, dynamic> m) {
    final exMap = Map<String, dynamic>.from((m['exercise'] ?? {}) as Map);
    final muscleIndex = _asInt(exMap['primaryMuscle']) ?? MuscleGroup.fullBody.index;

    final exercise = Exercise(
      id: exMap['id'] as String? ?? 'unknown',
      name: exMap['name'] as String? ?? 'Unknown Exercise',
      primaryMuscle:
          MuscleGroup.values[_clampIndex(muscleIndex, MuscleGroup.values.length)],
    );

    final equipment = _asList(m['equipment'])
        .map((eq) {
          final map = Map<String, dynamic>.from(eq as Map);
          final catIndex = _asInt(map['category']) ?? EquipmentCategory.accessories.index;
          return Equipment(
            id: map['id'] as String? ?? 'unknown',
            name: map['name'] as String? ?? 'Unknown Equipment',
            category:
                EquipmentCategory.values[_clampIndex(catIndex, EquipmentCategory.values.length)],
          );
        })
        .toList();

    final sets = _asList(m['sets'])
        .map((s) => _setFromMap(Map<String, dynamic>.from(s as Map)))
        .toList();

    return WorkoutExerciseEntry(
      exercise: exercise,
      equipment: equipment,
      sets: sets,
      note: m['note'] as String?,
      exerciseDurationSeconds: _asInt(m['exerciseDurationSeconds']),
      restAfterExerciseSeconds: _asInt(m['restAfterExerciseSeconds']),
    );
  }

  WorkoutSet _setFromMap(Map<String, dynamic> m) {
    return WorkoutSet(
      reps: _asInt(m['reps']),
      weightKg: _asDouble(m['weightKg']),
      durationSeconds: _asInt(m['durationSeconds']),
      tempoEccentric: _asInt(m['tempoEccentric']),
      tempoPause1: _asInt(m['tempoPause1']),
      tempoConcentric: _asInt(m['tempoConcentric']),
      tempoPause2: _asInt(m['tempoPause2']),
      distanceKm: _asDouble(m['distanceKm']),
      calories: _asInt(m['calories']),
      rpe: _asInt(m['rpe']),
      restSeconds: _asInt(m['restSeconds']) ?? 90,
      note: m['note'] as String?,
    );
  }

  WarmupCooldownItem _warmupFromMap(Map<String, dynamic> m) {
    final typeIndex = _asInt(m['type']) ?? WarmupCooldownType.both.index;
    final catIndex =
        _asInt(m['category']) ?? WarmupCooldownCategory.mobilityDrills.index;

    return WarmupCooldownItem(
      id: m['id'] as String? ?? 'unknown',
      name: m['name'] as String? ?? 'Unknown Item',
      type: WarmupCooldownType
          .values[_clampIndex(typeIndex, WarmupCooldownType.values.length)],
      category: WarmupCooldownCategory
          .values[_clampIndex(catIndex, WarmupCooldownCategory.values.length)],
    );
  }

  ActiveWorkoutItemState _activeWorkoutItemStateFromMap(Map<String, dynamic> m) {
    return ActiveWorkoutItemState(
      goalReps: _asInt(m['goalReps']),
      reps: _asInt(m['reps']),
      done: m['done'] == true,
    );
  }

  List _asList(dynamic value) => value is List ? value : const [];

  int _clampIndex(int value, int length) {
    if (length <= 0) return 0;
    if (value < 0) return 0;
    if (value >= length) return length - 1;
    return value;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class ActiveWorkoutSession {
  final Workout workout;
  final int elapsedSeconds;
  final int restSecondsRemaining;
  final int? restingItemIndex;
  final int? activeIndex;
  final DateTime updatedAt;
  final List<ActiveWorkoutItemState> items;

  const ActiveWorkoutSession({
    required this.workout,
    required this.elapsedSeconds,
    required this.restSecondsRemaining,
    required this.restingItemIndex,
    required this.activeIndex,
    required this.updatedAt,
    required this.items,
  });
}

class ActiveWorkoutItemState {
  final int? goalReps;
  final int? reps;
  final bool done;

  const ActiveWorkoutItemState({
    required this.goalReps,
    required this.reps,
    required this.done,
  });
}
