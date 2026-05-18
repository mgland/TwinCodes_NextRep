import 'dart:async';

import 'package:flutter/material.dart';

import '../data/workout_storage.dart';
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
  int? _restingItemIndex;
  int? _activeIndex;
  late final Map<int, int?> _previousSessionRepsByItemIndex;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _topChipScrollController = ScrollController();
  final GlobalKey _railLayerKey = GlobalKey();
  late final List<GlobalKey> _railAnchorKeys;
  late final List<GlobalKey> _cardKeys;
  late final List<GlobalKey> _cardHeaderKeys;
  List<_RailNode> _railNodes = const [];
  bool _measureScheduled = false;
  double _scrollOffset = 0.0;
  double _topChipScrollOffset = 0.0;
  double _topChipMaxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _items = _buildItems(widget.workout);
    _previousSessionRepsByItemIndex =
      _buildPreviousSessionReps(widget.workout, _items);
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.kind != _DoingItemKind.exercise) continue;
      final prev = _previousSessionRepsByItemIndex[i];
      item.goalReps = prev;
      item.reps = prev;
    }
    _railAnchorKeys = List.generate(_items.length, (_) => GlobalKey());
    _cardKeys = List.generate(_items.length, (_) => GlobalKey());
    _cardHeaderKeys = List.generate(_items.length, (_) => GlobalKey());
    _activeIndex = _items.isEmpty ? null : 0;
    _scrollController.addListener(_scheduleRailMeasurement);
    _scrollController.addListener(_updateScrollOffset);
    _topChipScrollController.addListener(_updateTopChipScrollMetrics);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds += 1;
        if (_restSecondsRemaining > 0) {
          _restSecondsRemaining -= 1;
          if (_restSecondsRemaining == 0) {
            _restingItemIndex = null;
          }
        }
      });
    });
    _scheduleRailMeasurement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTopChipScrollMetrics();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scrollController.removeListener(_scheduleRailMeasurement);
    _scrollController.removeListener(_updateScrollOffset);
    _topChipScrollController.removeListener(_updateTopChipScrollMetrics);
    _scrollController.dispose();
    _topChipScrollController.dispose();
    super.dispose();
  }

  void _updateScrollOffset() {
    if (!mounted) return;
    final offset = _scrollController.hasClients ? _scrollController.offset.clamp(0.0, double.infinity) : 0.0;
    if ((offset - _scrollOffset).abs() > 0.5) {
      setState(() => _scrollOffset = offset);
    }
  }

  void _updateTopChipScrollMetrics() {
    if (!mounted) return;
    final position = _topChipScrollController.hasClients
        ? _topChipScrollController.position
        : null;
    final offset = position?.pixels.clamp(0.0, double.infinity) ?? 0.0;
    final maxExtent = position?.maxScrollExtent.clamp(0.0, double.infinity) ?? 0.0;
    if ((offset - _topChipScrollOffset).abs() > 0.5 ||
        (maxExtent - _topChipMaxScrollExtent).abs() > 0.5) {
      setState(() {
        _topChipScrollOffset = offset;
        _topChipMaxScrollExtent = maxExtent;
      });
    }
  }

  void _scheduleRailMeasurement() {
    if (_measureScheduled || !mounted) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      _measureRailGeometry();
    });
  }

  Color _railColorForIndex(int index) {
    final item = _items[index];
    final isActive = index == _activeIndex;
    if (isActive) return const Color(0xFF63C59A);
    if (item.done) return const Color(0xFF4FAE84);
    return const Color(0xFF6E757A);
  }

  void _measureRailGeometry() {
    if (!mounted) return;
    final layerContext = _railLayerKey.currentContext;
    if (layerContext == null) return;
    final layerBox = layerContext.findRenderObject();
    if (layerBox is! RenderBox) return;

    final measured = <_RailNode>[];
    for (int i = 0; i < _items.length; i++) {
      final anchorContext = _railAnchorKeys[i].currentContext;
      final cardContext = _cardKeys[i].currentContext;
      final headerContext = _cardHeaderKeys[i].currentContext;
      if (anchorContext == null || cardContext == null) continue;

      final anchorBox = anchorContext.findRenderObject();
      final cardBox = cardContext.findRenderObject();
      final headerBox = headerContext?.findRenderObject();
      if (anchorBox is! RenderBox || cardBox is! RenderBox) continue;

      final anchorOffset = anchorBox.localToGlobal(
        Offset.zero,
        ancestor: layerBox,
      );
      final cardOffset = cardBox.localToGlobal(
        Offset.zero,
        ancestor: layerBox,
      );
      final headerOffset = headerBox is RenderBox
          ? headerBox.localToGlobal(
              Offset.zero,
              ancestor: layerBox,
            )
          : null;
      final headerCenterY = headerBox is RenderBox && headerOffset != null
          ? headerOffset.dy + (headerBox.size.height / 2)
          : null;

      measured.add(
        _RailNode(
          x: anchorOffset.dx + (anchorBox.size.width / 2),
          y: headerCenterY ?? (cardOffset.dy + (cardBox.size.height / 2)),
          cardLeft: cardOffset.dx,
          color: _railColorForIndex(i),
          isActive: i == _activeIndex,
        ),
      );
    }

    if (!_sameNodes(_railNodes, measured)) {
      setState(() => _railNodes = measured);
    }
  }

  bool _sameNodes(List<_RailNode> a, List<_RailNode> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if ((a[i].x - b[i].x).abs() > 0.5) return false;
      if ((a[i].y - b[i].y).abs() > 0.5) return false;
      if ((a[i].cardLeft - b[i].cardLeft).abs() > 0.5) return false;
      if (a[i].color != b[i].color) return false;
      if (a[i].isActive != b[i].isActive) return false;
    }
    return true;
  }

  List<_DoingItemState> _buildItems(Workout workout) {
    final out = <_DoingItemState>[];
    for (final w in workout.warmups) {
      out.add(_DoingItemState(
        title: w.name,
        subtitle: 'Warm-up',
        kind: _DoingItemKind.warmup,
        exerciseId: null,
        setIndex: null,
        goalReps: null,
        reps: null,
        restSeconds: 30,
      ));
    }

    for (final e in workout.exercises) {
      if (e.sets.isEmpty) {
        out.add(_DoingItemState(
          title: '${e.exercise.name} Set 1',
          subtitle: 'Set 1',
          kind: _DoingItemKind.exercise,
          exerciseId: e.exercise.id,
          setIndex: 0,
          goalReps: null,
          reps: null,
          restSeconds: e.restAfterExerciseSeconds ?? 90,
        ));
        continue;
      }

      for (int setIndex = 0; setIndex < e.sets.length; setIndex++) {
        final set = e.sets[setIndex];
        final isLastSet = setIndex == e.sets.length - 1;
        final setRest = isLastSet
            ? (e.restAfterExerciseSeconds ?? set.restSeconds)
            : set.restSeconds;
        out.add(_DoingItemState(
          title: '${e.exercise.name} Set ${setIndex + 1}',
          subtitle: 'Set ${setIndex + 1}',
          kind: _DoingItemKind.exercise,
          exerciseId: e.exercise.id,
          setIndex: setIndex,
          goalReps: null,
          reps: null,
          restSeconds: setRest,
        ));
      }
    }

    for (final c in workout.cooldowns) {
      out.add(_DoingItemState(
        title: c.name,
        subtitle: 'Cool-down',
        kind: _DoingItemKind.cooldown,
        exerciseId: null,
        setIndex: null,
        goalReps: null,
        reps: null,
        restSeconds: 20,
      ));
    }
    return out;
  }

  Map<int, int?> _buildPreviousSessionReps(
    Workout current,
    List<_DoingItemState> items,
  ) {
    final history = WorkoutStorage.instance.getAllWorkouts();
    final out = <int, int?>{};

    bool isSameWorkout(Workout w) {
      if (current.storageKey != null && w.storageKey != null) {
        return current.storageKey == w.storageKey;
      }
      return w.name == current.name &&
          w.createdAt.millisecondsSinceEpoch ==
              current.createdAt.millisecondsSinceEpoch;
    }

    for (int itemIndex = 0; itemIndex < items.length; itemIndex++) {
      final item = items[itemIndex];
      if (item.kind != _DoingItemKind.exercise ||
          item.exerciseId == null ||
          item.setIndex == null) {
        out[itemIndex] = null;
        continue;
      }

      int? prevReps;
      for (final w in history) {
        if (isSameWorkout(w)) continue;

        WorkoutExerciseEntry? match;
        for (final entry in w.exercises) {
          if (entry.exercise.id == item.exerciseId) {
            match = entry;
            break;
          }
        }
        if (match == null) continue;
        if (item.setIndex! >= match.sets.length) continue;

        final reps = match.sets[item.setIndex!].reps;
        if (reps != null) {
          prevReps = reps;
          break;
        }
      }

      out[itemIndex] = prevReps;
    }

    return out;
  }

  void _toggleDone(int index) {
    setState(() {
      final item = _items[index];
      item.done = !item.done;
      if (item.done) {
        if ((item.reps ?? 0) <= 0) item.reps = item.goalReps;
        _restSecondsRemaining = item.restSeconds;
        _restingItemIndex = item.restSeconds > 0 ? index : null;
        final next = _items.indexWhere((it) => !it.done, index + 1);
        _activeIndex = next == -1 ? index : next;
      } else {
        _restSecondsRemaining = 0;
        if (_restingItemIndex == index) {
          _restingItemIndex = null;
        }
        _activeIndex = index;
      }
    });
    _scheduleRailMeasurement();
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
    final topExercises = widget.workout.exercises;
    final doneSetsByExercise = <String, int>{};
    for (final item in _items) {
      if (item.kind != _DoingItemKind.exercise || item.exerciseId == null) continue;
      if (!item.done) continue;
      doneSetsByExercise[item.exerciseId!] =
          (doneSetsByExercise[item.exerciseId!] ?? 0) + 1;
    }

    final warmupTotal = _items.where((i) => i.kind == _DoingItemKind.warmup).length;
    final warmupDone = _items.where((i) => i.kind == _DoingItemKind.warmup && i.done).length;
    final cooldownTotal = _items.where((i) => i.kind == _DoingItemKind.cooldown).length;
    final cooldownDone = _items.where((i) => i.kind == _DoingItemKind.cooldown && i.done).length;

    final topChips = <_TopChipData>[];
    if (warmupTotal > 0) {
      topChips.add(_TopChipData(
        label: 'Warm-Ups',
        progress: warmupDone / warmupTotal,
        fillColor: const Color(0xFF9A744C),
      ));
    }

    for (int i = 0; i < topExercises.length; i++) {
      final ex = topExercises[i];
      final totalSets = ex.sets.isEmpty ? 1 : ex.sets.length;
      final doneSets = (doneSetsByExercise[ex.exercise.id] ?? 0).clamp(0, totalSets);
      topChips.add(_TopChipData(
        label: '${i + 1}. ${ex.exercise.name}',
        progress: totalSets == 0 ? 0 : doneSets / totalSets,
        fillColor: const Color(0xFF2A6B52),
      ));
    }

    if (cooldownTotal > 0) {
      topChips.add(_TopChipData(
        label: 'Cool-Down',
        progress: cooldownDone / cooldownTotal,
        fillColor: const Color(0xFF4F7E9A),
      ));
    }

    int currentChipIndex = -1;
    for (int i = 0; i < topChips.length; i++) {
      if (topChips[i].progress < 1) {
        currentChipIndex = i;
        break;
      }
    }
    final currentChipPosition = currentChipIndex == -1
        ? topChips.length
        : currentChipIndex + 1;
    final now = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTopChipScrollMetrics();
    });

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
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
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
                        '$currentChipPosition/${topChips.length} Items',
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
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: _topChipScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int i = 0; i < topChips.length; i++) ...[
                                _ExerciseProgressChip(
                                  label: topChips[i].label,
                                  progress: topChips[i].progress,
                                  fillColor: topChips[i].fillColor,
                                  isActive: i == currentChipIndex,
                                ),
                                const SizedBox(width: 6),
                              ]
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: (_topChipScrollOffset / 7.0).clamp(0.0, 1.0),
                              child: Container(
                                width: 7,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF111B1F),
                                      Color(0xCC111B1F),
                                      Color(0x00111B1F),
                                    ],
                                    stops: [0.0, 0.55, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: ((_topChipMaxScrollExtent - _topChipScrollOffset) / 7.0)
                                  .clamp(0.0, 1.0),
                              child: Container(
                                width: 7,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      Color(0xFF1A2A2F),
                                      Color(0xCC1A2A2F),
                                      Color(0x001A2A2F),
                                    ],
                                    stops: [0.0, 0.55, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              key: _railLayerKey,
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _WorkoutBranchPainter(nodes: _railNodes),
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isActive = index == _activeIndex;
                    final prevReps = _previousSessionRepsByItemIndex[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                key: _railAnchorKeys[index],
                                width: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _activeIndex = index);
                                      _scheduleRailMeasurement();
                                    },
                                    child: AnimatedContainer(
                                      key: _cardKeys[index],
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
                                            key: _cardHeaderKeys[index],
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
                                              if (prevReps != null)
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
                                                      ? const Icon(
                                                          Icons.check,
                                                          color: Color(0xFF042111),
                                                          size: 16,
                                                        )
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
                                          if (isActive &&
                                              item.kind == _DoingItemKind.exercise) ...[
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
                                                    item.reps?.toString() ?? '',
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
                                                  onTap: () => setState(() {
                                                    item.reps = (item.reps ?? 0) + 1;
                                                  }),
                                                ),
                                                const SizedBox(width: 6),
                                                _MiniCircleButton(
                                                  label: '-',
                                                  color: const Color(0xFFE45252),
                                                  onTap: () => setState(() {
                                                    final current = item.reps;
                                                    if (current == null) return;
                                                    item.reps = current > 0 ? current - 1 : 0;
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
                              ),
                            ],
                          ),
                        ),
                        if (_restingItemIndex == index && _restSecondsRemaining > 0)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 0, 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timelapse,
                                  color: Color(0xFF63C59A),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Resting:',
                                  style: TextStyle(
                                    color: Color(0xFF63C59A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _fmtClock(_restSecondsRemaining),
                                  style: const TextStyle(
                                    color: Color(0xFFD8DEE4),
                                    fontSize: 34,
                                    height: 0.9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: (_scrollOffset / 40.0).clamp(0.0, 1.0),
                      child: Container(
                        height: 34,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF0D1B1E),
                              Color(0xE60D1B1E),
                              Color(0x8C0D1B1E),
                              Color(0x000D1B1E),
                            ],
                            stops: [0.0, 0.32, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 34,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFF0D1B1E),
                            Color(0xE60D1B1E),
                            Color(0x8C0D1B1E),
                            Color(0x000D1B1E),
                          ],
                          stops: [0.0, 0.32, 0.7, 1.0],
                        ),
                      ),
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

class _ExerciseProgressChip extends StatelessWidget {
  final String label;
  final double progress;
  final Color fillColor;
  final bool isActive;

  const _ExerciseProgressChip({
    required this.label,
    required this.progress,
    required this.fillColor,
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
              child: Container(color: fillColor),
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

class _TopChipData {
  final String label;
  final double progress;
  final Color fillColor;

  const _TopChipData({
    required this.label,
    required this.progress,
    required this.fillColor,
  });
}

class _RailNode {
  final double x;
  final double y;
  final double cardLeft;
  final Color color;
  final bool isActive;

  const _RailNode({
    required this.x,
    required this.y,
    required this.cardLeft,
    required this.color,
    required this.isActive,
  });
}

class _WorkoutBranchPainter extends CustomPainter {
  final List<_RailNode> nodes;

  const _WorkoutBranchPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;
    const nodeRadius = 4.0;

    final sorted = [...nodes]..sort((a, b) => a.y.compareTo(b.y));

    for (int i = 0; i < sorted.length - 1; i++) {
      final a = sorted[i];
      final b = sorted[i + 1];
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = LinearGradient(
          colors: [a.color.withAlpha(220), b.color.withAlpha(220)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTRB(a.x - 1, a.y, a.x + 1, b.y));
      canvas.drawLine(Offset(a.x, a.y), Offset(a.x, b.y), p);
    }

    _drawDashedFadeVertical(
      canvas,
      x: sorted.first.x,
      startY: 0,
      endY: sorted.first.y,
      color: sorted.first.color,
      fadeOutAtStart: true,
    );
    _drawDashedFadeVertical(
      canvas,
      x: sorted.last.x,
      startY: sorted.last.y,
      endY: size.height - 8,
      color: sorted.last.color,
      fadeOutAtStart: false,
    );

    for (final node in sorted) {
      final connectorEnd = node.cardLeft.clamp(node.x, size.width);
      final armPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = node.color.withAlpha(220);
      canvas.drawLine(Offset(node.x, node.y), Offset(connectorEnd, node.y), armPaint);

      final tipPaint = Paint()..color = node.color.withAlpha(230);
      canvas.drawCircle(Offset(connectorEnd, node.y), nodeRadius, tipPaint);

      if (node.isActive) {
        final glowPaint = Paint()..color = node.color.withAlpha(90);
        canvas.drawCircle(Offset(node.x, node.y), 8, glowPaint);
      }

      final nodePaint = Paint()..color = node.color;
      canvas.drawCircle(Offset(node.x, node.y), nodeRadius, nodePaint);
    }
  }

  void _drawDashedFadeVertical(
    Canvas canvas, {
    required double x,
    required double startY,
    required double endY,
    required Color color,
    required bool fadeOutAtStart,
  }) {
    if (endY <= startY + 2) return;
    final span = endY - startY;
    const dash = 7.0;
    const gap = 5.0;
    double y = startY;

    while (y < endY) {
      final next = (y + dash).clamp(startY, endY);
      final mid = (y + next) / 2;
      final t = ((mid - startY) / span).clamp(0.0, 1.0);
      final alphaFactor = fadeOutAtStart ? t : (1 - t);
      final p = Paint()
        ..strokeWidth = 2
        ..color = color.withAlpha((210 * alphaFactor).round());
      canvas.drawLine(Offset(x, y), Offset(x, next), p);
      y = next + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutBranchPainter oldDelegate) {
    if (oldDelegate.nodes.length != nodes.length) return true;
    for (int i = 0; i < nodes.length; i++) {
      if ((oldDelegate.nodes[i].x - nodes[i].x).abs() > 0.1) return true;
      if ((oldDelegate.nodes[i].y - nodes[i].y).abs() > 0.1) return true;
      if ((oldDelegate.nodes[i].cardLeft - nodes[i].cardLeft).abs() > 0.1) return true;
      if (oldDelegate.nodes[i].color != nodes[i].color) return true;
      if (oldDelegate.nodes[i].isActive != nodes[i].isActive) return true;
    }
    return false;
  }
}

enum _DoingItemKind { warmup, exercise, cooldown }

class _DoingItemState {
  final String title;
  final String subtitle;
  final _DoingItemKind kind;
  final String? exerciseId;
  final int? setIndex;
  int? goalReps;
  final int restSeconds;
  int? reps;
  bool done = false;

  _DoingItemState({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.exerciseId,
    required this.setIndex,
    required this.goalReps,
    required this.reps,
    required this.restSeconds,
  });
}
