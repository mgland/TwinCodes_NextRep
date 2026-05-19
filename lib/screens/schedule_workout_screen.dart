import 'package:flutter/material.dart';
import '../data/workout_storage.dart';
import '../data/schedule_storage.dart';
import '../models/workout.dart';
import '../models/schedule.dart';

import '_time_preset_sheet.dart';

const _bg = Color(0xFF0D1B1E);
const _surface = Color(0xFF152126);
const _surface2 = Color(0xFF1E2E33);
const _accent = Color(0xFF2A9D8F);
const _subtle = Color(0xFF8A9BA8);
const _dimmer = Color(0xFF566A72);

class ScheduleWorkoutScreen extends StatefulWidget {
  const ScheduleWorkoutScreen({super.key});

  @override
  State<ScheduleWorkoutScreen> createState() => _ScheduleWorkoutScreenState();
}

class _ScheduleWorkoutScreenState extends State<ScheduleWorkoutScreen> {
  List<Workout> _workouts = [];
  DateTime _selectedDate = DateTime.now();
  bool _isCalendarExpanded = false;
  Set<int?> _expandedSchedules = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _workouts = WorkoutStorage.instance.getAllWorkouts();
    });
  }

  String _extractEquipmentFromWorkout(Workout workout) {
    final equipmentSet = <String>{};
    for (final entry in workout.exercises) {
      for (final equipment in entry.equipment) {
        equipmentSet.add(equipment.name);
      }
    }
    return equipmentSet.join(', ');
  }

  Future<void> _scheduleWorkout(Workout workout) async {
    final equipment = _extractEquipmentFromWorkout(workout);
    
    final schedule = WorkoutSchedule(
      workoutId: workout.storageKey?.toString() ?? '',
      workoutName: workout.name,
      workoutCategory: workout.category,
      scheduledDate: _selectedDate,
      description: equipment.isNotEmpty ? equipment : null,
    );

    await ScheduleStorage.instance.saveSchedule(schedule);
    _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${workout.name} scheduled for ${_formatDate(_selectedDate)}'),
        backgroundColor: _accent,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == yesterday) return 'Yesterday';
    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';

    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayOfWeek = date.weekday;
    return '${days[dayOfWeek - 1]} ${date.day} ${months[date.month]}';
  }

  List<WorkoutSchedule> _getSchedulesForSelectedDate() {
    return ScheduleStorage.instance.getSchedulesForDate(_selectedDate);
  }

  Future<void> _setTime(WorkoutSchedule schedule) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TimePresetSheet(
        schedule: schedule,
        onPicked: (hour, minute) async {
          schedule.scheduledTime = ScheduledTime(hour: hour, minute: minute);
          await ScheduleStorage.instance.saveSchedule(schedule);
          _loadData();
          if (!mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedulesForDate = _getSchedulesForSelectedDate();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        automaticallyImplyLeading: true,
        titleSpacing: 16,
        title: const Text(
          'Schedule Workout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
        children: [
          // ── Calendar Section ──────────────────────────────────────────────────
          _CalendarSection(
            selectedDate: _selectedDate,
            isExpanded: _isCalendarExpanded,
            onDateChanged: (date) {
              setState(() => _selectedDate = date);
            },
            onExpandToggle: () {
              setState(() => _isCalendarExpanded = !_isCalendarExpanded);
            },
          ),

          // ── Selected Date Label ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ── Scheduled Workouts for This Date ──────────────────────────────────
          if (schedulesForDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accent.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${schedulesForDate.length} scheduled',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final schedule in schedulesForDate)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _surface2),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: schedule.completed ? Colors.green : _subtle,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      schedule.workoutName,
                                      style: TextStyle(
                                        color: schedule.completed ? _dimmer : Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _setTime(schedule),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _accent.withAlpha(44),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            color: _accent,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            schedule.scheduledTime?.format() ?? 'Set',
                                            style: const TextStyle(
                                              color: _accent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      await ScheduleStorage.instance
                                          .deleteSchedule(schedule.storageKey ?? 0);
                                      _loadData();
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: _dimmer,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_expandedSchedules.contains(schedule.storageKey)) {
                                        _expandedSchedules.remove(schedule.storageKey);
                                      } else {
                                        _expandedSchedules.add(schedule.storageKey);
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _surface2,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Equipment: ${schedule.description!}',
                                                style: const TextStyle(
                                                  color: _dimmer,
                                                  fontSize: 11,
                                                ),
                                                maxLines: _expandedSchedules.contains(schedule.storageKey) ? null : 1,
                                                overflow: _expandedSchedules.contains(schedule.storageKey) ? TextOverflow.visible : TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── Workout Library ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Add Workout to ${_formatDate(_selectedDate)}',
              style: const TextStyle(
                color: _subtle,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: _workouts.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _surface2),
                    ),
                    child: Text(
                      'No workouts available. Create a workout first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _dimmer,
                        fontSize: 13,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final workout in _workouts)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _surface2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workout.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${workout.exercises.length} exercise(s) • ${workout.category.shortName}',
                                        style: const TextStyle(
                                          color: _subtle,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => _scheduleWorkout(workout),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _accent.withAlpha(44),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: _accent,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CalendarSection extends StatelessWidget {
  final DateTime selectedDate;
  final bool isExpanded;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onExpandToggle;

  const _CalendarSection({
    required this.selectedDate,
    required this.isExpanded,
    required this.onDateChanged,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExpanded)
            _FullCalendarView(
              selectedDate: selectedDate,
              onDateChanged: onDateChanged,
            )
          else
            _CompactCalendarView(
              selectedDate: selectedDate,
              onDateChanged: onDateChanged,
            ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onExpandToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: _accent,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  isExpanded ? 'Collapse' : 'Expand',
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactCalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _CompactCalendarView({
    required this.selectedDate,
    required this.onDateChanged,
  });

  bool _dateHasSchedules(DateTime date) {
    final allSchedules = ScheduleStorage.instance.getAllSchedules();
    final dateOnly = DateTime(date.year, date.month, date.day);
    return allSchedules.any((s) {
      final sDateOnly = DateTime(s.scheduledDate.year, s.scheduledDate.month, s.scheduledDate.day);
      return sDateOnly == dateOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(14, (i) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day).add(Duration(days: i - 3));
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final date in dates) ...[
            GestureDetector(
              onTap: () => onDateChanged(date),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 50,
                    decoration: BoxDecoration(
                      color: DateTime(date.year, date.month, date.day) ==
                              DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
                          ? _accent
                          : _surface2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: DateTime(date.year, date.month, date.day) ==
                                      DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
                                  ? Colors.white
                                  : _subtle,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_dateHasSchedules(date))
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dayName(date.weekday),
                    style: const TextStyle(
                      color: _dimmer,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ]
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

class _FullCalendarView extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _FullCalendarView({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<_FullCalendarView> createState() => _FullCalendarViewState();
}

class _FullCalendarViewState extends State<_FullCalendarView> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  void _previousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  bool _dateHasSchedules(DateTime date) {
    final allSchedules = ScheduleStorage.instance.getAllSchedules();
    final dateOnly = DateTime(date.year, date.month, date.day);
    return allSchedules.any((s) {
      final sDateOnly = DateTime(s.scheduledDate.year, s.scheduledDate.month, s.scheduledDate.day);
      return sDateOnly == dateOnly;
    });
  }

  List<List<int?>> _buildCalendarGrid() {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final lastDay = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday;

    final grid = <List<int?>>[];
    var week = List<int?>.filled(7, null);

    for (int i = 0; i < startingWeekday - 1; i++) {
      week[i] = null;
    }

    int dayIndex = startingWeekday - 1;
    for (int day = 1; day <= daysInMonth; day++) {
      week[dayIndex] = day;
      dayIndex++;
      if (dayIndex == 7) {
        grid.add(List.of(week));
        week = List.filled(7, null);
        dayIndex = 0;
      }
    }
    if (dayIndex > 0) {
      grid.add(week);
    }

    return grid;
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final grid = _buildCalendarGrid();
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _previousMonth,
              child: const Icon(Icons.chevron_left, color: _accent),
            ),
            Text(
              '${_monthName(_displayMonth.month)} ${_displayMonth.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: _nextMonth,
              child: const Icon(Icons.chevron_right, color: _accent),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dayLabels
              .map((day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: _dimmer,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        for (final week in grid)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final day in week)
                  GestureDetector(
                    onTap: day != null
                        ? () {
                            final selectedDay =
                                DateTime(_displayMonth.year, _displayMonth.month, day);
                            widget.onDateChanged(selectedDay);
                          }
                        : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: day != null
                            ? (DateTime(_displayMonth.year, _displayMonth.month, day) ==
                                    DateTime(widget.selectedDate.year, widget.selectedDate.month,
                                        widget.selectedDate.day)
                                ? _accent
                                : _surface2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (day != null)
                            Center(
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  color: DateTime(_displayMonth.year, _displayMonth.month, day) ==
                                          DateTime(widget.selectedDate.year,
                                              widget.selectedDate.month, widget.selectedDate.day)
                                      ? Colors.white
                                      : _subtle,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (day != null && _dateHasSchedules(DateTime(_displayMonth.year, _displayMonth.month, day)))
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
