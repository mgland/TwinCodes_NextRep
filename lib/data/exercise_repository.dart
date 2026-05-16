import '../models/exercise.dart';

class ExerciseRepository {
  static final ExerciseRepository instance = ExerciseRepository._();

  ExerciseRepository._();

  final List<Exercise> exercises = [
    // ── Chest ──────────────────────────────────────────────────────────────
    Exercise(
      id: 'c1',
      name: 'Barbell Bench Press',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    ),
    Exercise(
      id: 'c2',
      name: 'Cable Crossover',
      primaryMuscle: MuscleGroup.chest,
    ),
    Exercise(
      id: 'c3',
      name: 'Chest Press Machine',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.triceps],
    ),
    Exercise(
      id: 'c4',
      name: 'Decline Bench Press',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.triceps],
    ),
    Exercise(
      id: 'c5',
      name: 'Dumbbell Fly',
      primaryMuscle: MuscleGroup.chest,
    ),
    Exercise(
      id: 'c6',
      name: 'Incline Bench Press',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    ),
    Exercise(
      id: 'c7',
      name: 'Pec Deck Machine',
      primaryMuscle: MuscleGroup.chest,
    ),
    Exercise(
      id: 'c8',
      name: 'Push Up',
      primaryMuscle: MuscleGroup.chest,
      secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.core],
    ),
    // ── Back ───────────────────────────────────────────────────────────────
    Exercise(
      id: 'b1',
      name: 'Barbell Row',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps],
    ),
    Exercise(
      id: 'b2',
      name: 'Cable Pullover',
      primaryMuscle: MuscleGroup.back,
    ),
    Exercise(
      id: 'b3',
      name: 'Deadlift',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.legs, MuscleGroup.glutes, MuscleGroup.core],
    ),
    Exercise(
      id: 'b4',
      name: 'Dumbbell Single Arm Row',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps],
    ),
    Exercise(
      id: 'b5',
      name: 'Face Pull',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.shoulders],
    ),
    Exercise(
      id: 'b6',
      name: 'Lat Pull Down Normal Grip',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps],
    ),
    Exercise(
      id: 'b7',
      name: 'Pull Up',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps],
    ),
    Exercise(
      id: 'b8',
      name: 'Seated Cable Row',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps],
    ),
    Exercise(
      id: 'b9',
      name: 'T-Bar Row',
      primaryMuscle: MuscleGroup.back,
      secondaryMuscles: [MuscleGroup.biceps],
    ),
    // ── Shoulders ──────────────────────────────────────────────────────────
    Exercise(
      id: 's1',
      name: 'Arnold Press',
      primaryMuscle: MuscleGroup.shoulders,
    ),
    Exercise(
      id: 's2',
      name: 'Barbell Overhead Press',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: [MuscleGroup.triceps],
    ),
    Exercise(
      id: 's3',
      name: 'Cable Lateral Raise',
      primaryMuscle: MuscleGroup.shoulders,
    ),
    Exercise(
      id: 's4',
      name: 'Dumbbell Front Raise',
      primaryMuscle: MuscleGroup.shoulders,
    ),
    Exercise(
      id: 's5',
      name: 'Dumbbell Shoulder Press',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: [MuscleGroup.triceps],
    ),
    Exercise(
      id: 's6',
      name: 'Lateral Raises Dumbbell',
      primaryMuscle: MuscleGroup.shoulders,
    ),
    Exercise(
      id: 's7',
      name: 'Reverse Fly',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: [MuscleGroup.back],
    ),
    Exercise(
      id: 's8',
      name: 'Upright Row',
      primaryMuscle: MuscleGroup.shoulders,
      secondaryMuscles: [MuscleGroup.biceps],
    ),
    // ── Biceps ─────────────────────────────────────────────────────────────
    Exercise(
      id: 'bi1',
      name: 'Barbell Curl',
      primaryMuscle: MuscleGroup.biceps,
    ),
    Exercise(
      id: 'bi2',
      name: 'Cable Curl',
      primaryMuscle: MuscleGroup.biceps,
    ),
    Exercise(
      id: 'bi3',
      name: 'Concentration Curl',
      primaryMuscle: MuscleGroup.biceps,
    ),
    Exercise(
      id: 'bi4',
      name: 'Dumbbell Curl',
      primaryMuscle: MuscleGroup.biceps,
    ),
    Exercise(
      id: 'bi5',
      name: 'Hammer Curl',
      primaryMuscle: MuscleGroup.biceps,
      secondaryMuscles: [MuscleGroup.forearms],
    ),
    Exercise(
      id: 'bi6',
      name: 'Preacher Curl',
      primaryMuscle: MuscleGroup.biceps,
    ),
    // ── Triceps ────────────────────────────────────────────────────────────
    Exercise(
      id: 'tr1',
      name: 'Close Grip Bench Press',
      primaryMuscle: MuscleGroup.triceps,
      secondaryMuscles: [MuscleGroup.chest],
    ),
    Exercise(
      id: 'tr2',
      name: 'Dips',
      primaryMuscle: MuscleGroup.triceps,
      secondaryMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    ),
    Exercise(
      id: 'tr3',
      name: 'Kickbacks Tricep',
      primaryMuscle: MuscleGroup.triceps,
    ),
    Exercise(
      id: 'tr4',
      name: 'Overhead Tricep Extension',
      primaryMuscle: MuscleGroup.triceps,
    ),
    Exercise(
      id: 'tr5',
      name: 'Rope Pushdown',
      primaryMuscle: MuscleGroup.triceps,
    ),
    Exercise(
      id: 'tr6',
      name: 'Skull Crushers',
      primaryMuscle: MuscleGroup.triceps,
    ),
    // ── Legs ───────────────────────────────────────────────────────────────
    Exercise(
      id: 'l1',
      name: 'Bulgarian Split Squat',
      primaryMuscle: MuscleGroup.legs,
      secondaryMuscles: [MuscleGroup.glutes],
    ),
    Exercise(
      id: 'l2',
      name: 'Hack Squat',
      primaryMuscle: MuscleGroup.legs,
    ),
    Exercise(
      id: 'l3',
      name: 'Leg Curl Machine',
      primaryMuscle: MuscleGroup.legs,
    ),
    Exercise(
      id: 'l4',
      name: 'Leg Extension Machine',
      primaryMuscle: MuscleGroup.legs,
    ),
    Exercise(
      id: 'l5',
      name: 'Leg Press',
      primaryMuscle: MuscleGroup.legs,
      secondaryMuscles: [MuscleGroup.glutes],
    ),
    Exercise(
      id: 'l6',
      name: 'Lunges',
      primaryMuscle: MuscleGroup.legs,
      secondaryMuscles: [MuscleGroup.glutes],
    ),
    Exercise(
      id: 'l7',
      name: 'Romanian Deadlift',
      primaryMuscle: MuscleGroup.legs,
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back],
    ),
    Exercise(
      id: 'l8',
      name: 'Squat Barbell',
      primaryMuscle: MuscleGroup.legs,
      secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.core],
    ),
    // ── Core ───────────────────────────────────────────────────────────────
    Exercise(
      id: 'co1',
      name: 'Ab Wheel Rollout',
      primaryMuscle: MuscleGroup.core,
    ),
    Exercise(
      id: 'co2',
      name: 'Cable Crunch',
      primaryMuscle: MuscleGroup.core,
    ),
    Exercise(
      id: 'co3',
      name: 'Crunch',
      primaryMuscle: MuscleGroup.core,
    ),
    Exercise(
      id: 'co4',
      name: 'Hanging Leg Raise',
      primaryMuscle: MuscleGroup.core,
    ),
    Exercise(
      id: 'co5',
      name: 'Plank',
      primaryMuscle: MuscleGroup.core,
      secondaryMuscles: [MuscleGroup.shoulders],
    ),
    Exercise(
      id: 'co6',
      name: 'Russian Twist',
      primaryMuscle: MuscleGroup.core,
    ),
    // ── Glutes ─────────────────────────────────────────────────────────────
    Exercise(
      id: 'g1',
      name: 'Cable Kickback',
      primaryMuscle: MuscleGroup.glutes,
    ),
    Exercise(
      id: 'g2',
      name: 'Donkey Kick',
      primaryMuscle: MuscleGroup.glutes,
    ),
    Exercise(
      id: 'g3',
      name: 'Glute Bridge',
      primaryMuscle: MuscleGroup.glutes,
      secondaryMuscles: [MuscleGroup.core],
    ),
    Exercise(
      id: 'g4',
      name: 'Hip Thrust',
      primaryMuscle: MuscleGroup.glutes,
      secondaryMuscles: [MuscleGroup.legs],
    ),
    // ── Calves ─────────────────────────────────────────────────────────────
    Exercise(
      id: 'ca1',
      name: 'Calf Raise Machine',
      primaryMuscle: MuscleGroup.calves,
    ),
    Exercise(
      id: 'ca2',
      name: 'Seated Calf Raise',
      primaryMuscle: MuscleGroup.calves,
    ),
    Exercise(
      id: 'ca3',
      name: 'Standing Calf Raise',
      primaryMuscle: MuscleGroup.calves,
    ),
  ];
}
