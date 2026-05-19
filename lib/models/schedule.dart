import 'workout.dart';

class WorkoutSchedule {
  int? storageKey;
  String workoutId; // Reference to workout storageKey
  String workoutName;
  WorkoutCategory workoutCategory;
  DateTime scheduledDate;
  ScheduledTime? scheduledTime;
  String? description; // Equipment and other notes
  bool completed;
  DateTime createdAt;

  WorkoutSchedule({
    this.storageKey,
    required this.workoutId,
    required this.workoutName,
    required this.workoutCategory,
    required this.scheduledDate,
    this.scheduledTime,
    this.description,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class ScheduledTime {
  final int hour;
  final int minute;

  const ScheduledTime({required this.hour, required this.minute});

  String format() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory ScheduledTime.fromMinutes(int minutes) {
    return ScheduledTime(
      hour: minutes ~/ 60,
      minute: minutes % 60,
    );
  }

  int toMinutes() => hour * 60 + minute;
}
