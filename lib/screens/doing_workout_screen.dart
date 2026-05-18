import 'dart:async';

import 'package:flutter/material.dart';

import '../models/workout.dart';

class DoingWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const DoingWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<DoingWorkoutScreen> createState() => _DoingWorkoutScreenState();
}

class _DoingWorkoutScreenState extends State<DoingWorkoutScreen> {
  late final List<_DoingItemState> _items;
  Timer? _ticker;
  int _elapsedSeconds = 0;
  int _restSecondsRemaining = 0;
  int? _activeIndex;

  @override
  void initState() {
    super.initState();
    _items = _buildItems(widget.workout);
    _activeIndex = _items.isEmpty ? null : 0;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds += 1;
        if (_restSecondsRemaining > 0) {
          _restSecondsRemaining -= 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  List<_DoingItemState> _buildItems(Workout workout) {
    final out = <_DoingItemState>[];
    for (final w in workout.warmups) {
      out.add(_DoingItemState(
        title: w.name,
        subtitle: 'Warm-up',
        kind: _DoingItemKind.warmup,
        goalReps: 1,
        reps: 1,
        restSeconds: 30,
      ));
    }

    for (final e in workout.exercises) {
      final goal = e.sets.isNotEmpty ? (e.sets.first.reps ?? 8) : 8;
      final setCount = e.sets.length;
      out.add(_DoingItemState(
        title: e.exercise.name,
        subtitle: '$setCount set${setCount == 1 ? '' : 's'}',
        kind: _DoingItemKind.exercise,
        goalReps: goal,
        reps: goal,
        restSeconds: e.restAfterExerciseSeconds ??
            (e.sets.isNotEmpty ? e.sets.last.restSeconds : 90),
      ));
    }

    for (final c in workout.cooldowns) {
      out.add(_DoingItemState(
        title: c.name,
        subtitle: 'Cool-down',
        kind: _DoingItemKind.cooldown,
        goalReps: 1,
        reps: 1,
        restSeconds: 20,
      ));
    }
    return out;
  }

  List<_DoingItemState> get _exerciseItems =>
      _items.where((i) => i.kind == _DoingItemKind.exercise).toList();

  int get _currentExercisePosition {
    final exercises = _exerciseItems;
    if (exercises.isEmpty) return 0;
    final firstNotDone = exercises.indexWhere((e) => !e.done);
    if (firstNotDone == -1) return exercises.length;
    return firstNotDone + 1;
  }

  int? _previousReps(int index) {
    for (int i = index - 1; i >= 0; i--) {
      if (_items[i].done) return _items[i].reps;
    }
    if (index > 0) return _items[index - 1].reps;
    return null;
  }

  void _toggleDone(int index) {
    setState(() {
      final item = _items[index];
      item.done = !item.done;
      if (item.done) {
        if (item.reps <= 0) item.reps = item.goalReps;
        _restSecondsRemaining = item.restSeconds;
        final next = _items.indexWhere((it) => !it.done, index + 1);
        _activeIndex = next == -1 ? index : next;
      } else {
        _restSecondsRemaining = 0;
        _activeIndex = index;
      }
    });
  }

  String _fmtClock(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _fmtDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _exerciseItems;
    final doneExerciseCount = exercises.where((e) => e.done).length;
    final currentExerciseIndex = exercises.indexWhere((e) => !e.done);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B1E),
        title: Text(
          widget.workout.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF111B1F), Color(0xFF1A2A2F)],
                ),
                border: Border.all(color: const Color(0xFF1E2E33)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${_currentExercisePosition}/${exercises.length} Exercises',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _fmtDate(now),
                        style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _fmtClock(_elapsedSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 28,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < exercises.length; i++) ...[
                            _ExerciseProgressChip(
                              label: '${i + 1}. ${exercises[i].title}',
                              progress: i < doneExerciseCount
                                  ? 1
                                  : (i == currentExerciseIndex ? 0.55 : 0),
                              isActive: i == currentExerciseIndex,
                            ),
                            const SizedBox(width: 6),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_restSecondsRemaining > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.timelapse, color: Color(0xFF2FE26F), size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Resting:',
                    style: TextStyle(
                      color: Color(0xFF2FE26F),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _fmtClock(_restSecondsRemaining),
                    style: const TextStyle(
                      color: Color(0xFFD8DEE4),
                      fontSize: 38,
                      height: 0.9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isActive = index == _activeIndex;
                final prevReps = _previousReps(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BranchRail(
                        isFirst: index == 0,
                        isLast: index == _items.length - 1,
                        isDone: item.done,
                        isActive: isActive,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: isActive
                                  ? const LinearGradient(
                                      colors: [Color(0xFF1D3137), Color(0xFF233B40)],
                                    )
                                  : const LinearGradient(
                                      colors: [Color(0xFF18272C), Color(0xFF1B2C31)],
                                    ),
                              border: Border.all(
                                color: item.done
                                    ? const Color(0xFF27D16D)
                                    : isActive
                                        ? const Color(0xFF2A9D8F)
                                        : const Color(0xFF24373D),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          color: item.done
                                              ? const Color(0xFF32DA72)
                                              : Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if ((prevReps ?? 0) > 0)
                                      Text(
                                        'Prev: $prevReps',
                                        style: const TextStyle(
                                          color: Color(0xFF9AAAB3),
                                          fontSize: 12,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _toggleDone(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item.done
                                              ? const Color(0xFF28D66D)
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: item.done
                                                ? const Color(0xFF28D66D)
                                                : const Color(0xFF2DD06F),
                                            width: 2,
                                          ),
                                        ),
                                        child: item.done
                                            ? const Icon(Icons.check,
                                                color: Color(0xFF042111), size: 16)
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF8A9BA8),
                                    fontSize: 12,
                                  ),
                                ),
                                if (isActive) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        '${item.done ? 'Reps' : 'Goal'}:',
                                        style: const TextStyle(
                                          color: Color(0xFFD1D7DC),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 56,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: const Color(0xFF152126),
                                        ),
                                        child: Text(
                                          '${item.reps}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _MiniCircleButton(
                                        label: '=',
                                        onTap: () => setState(() {
                                          item.reps = prevReps ?? item.goalReps;
                                        }),
                                      ),
                                      const SizedBox(width: 6),
                                      _MiniCircleButton(
                                        label: '+',
                                        color: const Color(0xFF2FE26F),
                                        onTap: () => setState(() => item.reps += 1),
                                      ),
                                      const SizedBox(width: 6),
                                      _MiniCircleButton(
                                        label: '-',
                                        color: const Color(0xFFE45252),
                                        onTap: () => setState(() {
                                          item.reps = item.reps > 0 ? item.reps - 1 : 0;
                                        }),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseProgressChip extends StatelessWidget {
  final String label;
  final double progress;
  final bool isActive;

  const _ExerciseProgressChip({
    required this.label,
    required this.progress,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(color: Color(0xFF4A5358)),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFFD6DBDE),
                fontSize: 11,
              ),
            ),
          ),
          Positioned.fill(
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0, 1),
              alignment: Alignment.centerLeft,
              child: Container(color: isActive ? const Color(0xFF28D66D) : const Color(0xFF1F8E58)),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCircleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MiniCircleButton({
    required this.label,
    required this.onTap,
    this.color = const Color(0xFFB9C1C7),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF112026),
          border: Border.all(color: const Color(0xFF203238)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchRail extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isDone;
  final bool isActive;

  const _BranchRail({
    required this.isFirst,
    required this.isLast,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isActive
        ? const Color(0xFF3BFF86)
        : (isDone ? const Color(0xFF2FE26F) : const Color(0xFF6E757A));
    final lineColor = isDone
        ? const Color(0xFF1FCF68)
        : (isActive ? const Color(0xFF2A9D8F) : const Color(0xFF5D666B));

    return SizedBox(
      width: 22,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: isFirst
                ? _DashedFadeLine(color: lineColor, reverse: true)
                : Center(child: Container(width: 2, color: lineColor)),
          ),
          Container(
            width: isActive ? 12 : 10,
            height: isActive ? 12 : 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: dotColor.withAlpha(150),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(
            height: 52,
            child: isLast
                ? _DashedFadeLine(color: lineColor, reverse: false)
                : Center(child: Container(width: 2, color: lineColor)),
          ),
        ],
      ),
    );
  }
}

class _DashedFadeLine extends StatelessWidget {
  final Color color;
  final bool reverse;

  const _DashedFadeLine({
    required this.color,
    required this.reverse,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentCount = 5;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(segmentCount, (i) {
            final t = reverse ? (segmentCount - i) / segmentCount : (i + 1) / segmentCount;
            return Container(
              width: 2,
              height: constraints.maxHeight / (segmentCount * 1.7),
              color: color.withAlpha((255 * t).round()),
            );
          }),
        );
      },
    );
  }
}

enum _DoingItemKind { warmup, exercise, cooldown }

class _DoingItemState {
  final String title;
  final String subtitle;
  final _DoingItemKind kind;
  final int goalReps;
  final int restSeconds;
  int reps;
  bool done = false;

  _DoingItemState({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.goalReps,
    required this.reps,
    required this.restSeconds,
  });
}
