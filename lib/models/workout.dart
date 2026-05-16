import 'exercise.dart';
import 'equipment.dart';
import 'warmup_cooldown.dart';

// ── Workout category ──────────────────────────────────────────────────────────

enum WorkoutCategory {
  repBased,
  timeBased,
  tut,
  distanceCalorieRpe;

  String get displayName {
    switch (this) {
      case WorkoutCategory.repBased:
        return 'Repetition-Based';
      case WorkoutCategory.timeBased:
        return 'Time-Based';
      case WorkoutCategory.tut:
        return 'Time Under Tension (TUT)';
      case WorkoutCategory.distanceCalorieRpe:
        return 'Distance / Caloric / RPE';
    }
  }

  String get shortName {
    switch (this) {
      case WorkoutCategory.repBased:
        return 'Reps';
      case WorkoutCategory.timeBased:
        return 'Time';
      case WorkoutCategory.tut:
        return 'TUT';
      case WorkoutCategory.distanceCalorieRpe:
        return 'Dist / Cal / RPE';
    }
  }

  String get description {
    switch (this) {
      case WorkoutCategory.repBased:
        return 'Track sets, reps and weight. Classic strength training.';
      case WorkoutCategory.timeBased:
        return 'Set a duration per exercise or per set. Great for circuits.';
      case WorkoutCategory.tut:
        return 'Control tempo to maximise time under tension per set.';
      case WorkoutCategory.distanceCalorieRpe:
        return 'Log distance (km), calories burned, or perceived effort (RPE).';
    }
  }
}

// ── Set model ─────────────────────────────────────────────────────────────────

class WorkoutSet {
  // Rep-based
  int? reps; // null = AMRAP
  double? weightKg;

  // Time-based / TUT
  int? durationSeconds;

  // TUT tempo (eccentric/pause/concentric/pause)
  int? tempoEccentric;
  int? tempoPause1;
  int? tempoConcentric;
  int? tempoPause2;

  // Distance / Caloric / RPE
  double? distanceKm;
  int? calories;
  int? rpe; // 1-10

  // Rest after this set (seconds)
  int restSeconds;

  String? note;

  WorkoutSet({
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.tempoEccentric,
    this.tempoPause1,
    this.tempoConcentric,
    this.tempoPause2,
    this.distanceKm,
    this.calories,
    this.rpe,
    this.restSeconds = 90,
    this.note,
  });

  WorkoutSet copyWith({
    int? reps,
    double? weightKg,
    int? durationSeconds,
    int? tempoEccentric,
    int? tempoPause1,
    int? tempoConcentric,
    int? tempoPause2,
    double? distanceKm,
    int? calories,
    int? rpe,
    int? restSeconds,
    String? note,
    bool clearReps = false,
    bool clearWeight = false,
  }) {
    return WorkoutSet(
      reps: clearReps ? null : (reps ?? this.reps),
      weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
      durationSeconds: durationSeconds ?? this.durationSeconds,
      tempoEccentric: tempoEccentric ?? this.tempoEccentric,
      tempoPause1: tempoPause1 ?? this.tempoPause1,
      tempoConcentric: tempoConcentric ?? this.tempoConcentric,
      tempoPause2: tempoPause2 ?? this.tempoPause2,
      distanceKm: distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      rpe: rpe ?? this.rpe,
      restSeconds: restSeconds ?? this.restSeconds,
      note: note ?? this.note,
    );
  }
}

// ── Exercise entry inside a workout ──────────────────────────────────────────

class WorkoutExerciseEntry {
  final Exercise exercise;
  List<Equipment> equipment;
  List<WorkoutSet> sets;
  String? note;

  // Time-based: a single duration for the whole exercise (overrides set durations)
  int? exerciseDurationSeconds;

  // Rest between this exercise and the next (seconds); null = no rest
  int? restAfterExerciseSeconds;

  WorkoutExerciseEntry({
    required this.exercise,
    List<Equipment>? equipment,
    List<WorkoutSet>? sets,
    this.note,
    this.exerciseDurationSeconds,
    this.restAfterExerciseSeconds,
  })  : equipment = equipment ?? [],
        sets = sets ?? [WorkoutSet()];
}

// ── Top-level workout ─────────────────────────────────────────────────────────

class Workout {
  int? storageKey;
  String name;
  WorkoutCategory category;
  List<WorkoutExerciseEntry> exercises;
  List<WarmupCooldownItem> warmups;
  List<WarmupCooldownItem> cooldowns;
  String? note;
  DateTime createdAt;

  Workout({
    this.storageKey,
    required this.name,
    required this.category,
    List<WorkoutExerciseEntry>? exercises,
    List<WarmupCooldownItem>? warmups,
    List<WarmupCooldownItem>? cooldowns,
    this.note,
    DateTime? createdAt,
  })  : exercises = exercises ?? [],
        warmups = warmups ?? [],
        cooldowns = cooldowns ?? [],
        createdAt = createdAt ?? DateTime.now();
}
