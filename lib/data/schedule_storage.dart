import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../models/schedule.dart';
import '../models/workout.dart';

class ScheduleStorage {
  ScheduleStorage._();

  static final ScheduleStorage instance = ScheduleStorage._();

  static String get _boxName => '${AppConstants.hiveId}-schedules';

  Box<dynamic>? _box;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
    } on MissingPluginException {
      final dir = Directory('${Directory.systemTemp.path}/${AppConstants.appIdentifier}');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      Hive.init(dir.path);
    }
    _box ??= await Hive.openBox<dynamic>(_boxName);
  }

  Future<void> saveSchedule(WorkoutSchedule schedule) async {
    final box = await _ensureBox();
    if (schedule.storageKey != null && box.containsKey(schedule.storageKey)) {
      await box.put(schedule.storageKey, _scheduleToMap(schedule));
      return;
    }

    final key = await box.add(_scheduleToMap(schedule));
    schedule.storageKey = key;
  }

  List<WorkoutSchedule> getAllSchedules() {
    if (_box == null) return [];

    return _box!.toMap().entries
        .where((entry) => entry.value is Map)
        .map((entry) => _scheduleFromMap(
              Map<String, dynamic>.from(entry.value as Map),
              storageKey: entry.key is int ? entry.key as int : null,
            ))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  List<WorkoutSchedule> getSchedulesForDate(DateTime date) {
    final allSchedules = getAllSchedules();
    final dateOnly = DateTime(date.year, date.month, date.day);
    return allSchedules
        .where((s) => DateTime(s.scheduledDate.year, s.scheduledDate.month, s.scheduledDate.day) == dateOnly)
        .toList();
  }

  List<WorkoutSchedule> getUpcomingSchedules({int days = 7}) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    final allSchedules = getAllSchedules();
    return allSchedules
        .where((s) => s.scheduledDate.isAfter(now) && s.scheduledDate.isBefore(future))
        .toList();
  }

  Future<void> deleteSchedule(int storageKey) async {
    final box = await _ensureBox();
    await box.delete(storageKey);
  }

  Future<Box<dynamic>> _ensureBox() async {
    if (_box != null) return _box!;
    await init();
    return _box!;
  }

  Map<String, dynamic> _scheduleToMap(WorkoutSchedule s) {
    return {
      'workoutId': s.workoutId,
      'workoutName': s.workoutName,
      'workoutCategory': s.workoutCategory.index,
      'scheduledDate': s.scheduledDate.toIso8601String(),
      'scheduledTime': s.scheduledTime != null ? '${s.scheduledTime!.hour}:${s.scheduledTime!.minute}' : null,
      'description': s.description,
      'completed': s.completed,
      'createdAt': s.createdAt.toIso8601String(),
    };
  }

  WorkoutSchedule _scheduleFromMap(Map<String, dynamic> m, {int? storageKey}) {
    final categoryIndex = _asInt(m['workoutCategory']) ?? 0;
    final scheduledDateRaw = m['scheduledDate'] as String?;
    final scheduledDate = scheduledDateRaw == null
        ? DateTime.now()
        : DateTime.tryParse(scheduledDateRaw) ?? DateTime.now();
    final createdAtRaw = m['createdAt'] as String?;
    final createdAt =
        createdAtRaw == null ? DateTime.now() : DateTime.tryParse(createdAtRaw) ?? DateTime.now();

    ScheduledTime? timeOfDay;
    final timeStr = m['scheduledTime'] as String?;
    if (timeStr != null) {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final min = int.tryParse(parts[1]) ?? 0;
        timeOfDay = ScheduledTime(hour: h, minute: min);
      }
    }

    return WorkoutSchedule(
      storageKey: storageKey,
      workoutId: m['workoutId'] as String? ?? 'unknown',
      workoutName: m['workoutName'] as String? ?? 'Workout',
      workoutCategory: WorkoutCategory.values[_clampIndex(categoryIndex, WorkoutCategory.values.length)],
      scheduledDate: scheduledDate,
      scheduledTime: timeOfDay,
      description: m['description'] as String?,
      completed: m['completed'] == true,
      createdAt: createdAt,
    );
  }

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
}
