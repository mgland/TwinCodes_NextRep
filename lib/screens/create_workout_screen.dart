import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/equipment.dart';
import '../models/warmup_cooldown.dart';
import '../data/exercise_repository.dart';
import '../data/equipment_repository.dart';
import '../data/rest_preset_storage.dart';
import '../data/workout_storage.dart';
import '../data/warmup_cooldown_repository.dart';
import 'existing_workouts_screen.dart';
import 'workout_creation_pickers.dart';

// ── Shared palette ────────────────────────────────────────────────────────────

const _bg = Color(0xFF0D1B1E);
const _surface = Color(0xFF152126);
const _surface2 = Color(0xFF1E2E33);
const _accent = Color(0xFF2A9D8F);
const _subtle = Color(0xFF8A9BA8);
const _dimmer = Color(0xFF566A72);

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtSeconds(int s) {
  if (s <= 0) return '0s';
  final m = s ~/ 60;
  final sec = s % 60;
  if (m == 0) return '${s}s';
  if (sec == 0) return '${m}m';
  return '${m}m ${sec}s';
}

String _fmtTimeInputSeconds(int s) {
  if (s <= 0) return 'N/A';
  return _fmtSeconds(s);
}

IconData _muscleIcon(MuscleGroup muscle) {
  switch (muscle) {
    case MuscleGroup.chest:
    case MuscleGroup.shoulders:
    case MuscleGroup.triceps:
      return Icons.fitness_center_rounded;
    case MuscleGroup.back:
    case MuscleGroup.biceps:
    case MuscleGroup.forearms:
      return Icons.sports_gymnastics_rounded;
    case MuscleGroup.legs:
    case MuscleGroup.glutes:
    case MuscleGroup.calves:
      return Icons.directions_run_rounded;
    case MuscleGroup.core:
      return Icons.radio_button_checked_rounded;
    case MuscleGroup.fullBody:
      return Icons.accessibility_new_rounded;
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────

class CreateWorkoutScreen extends StatefulWidget {
  final WorkoutCategory category;
  final Workout? initialWorkout;
  final int? editingStorageKey;

  const CreateWorkoutScreen({
    super.key,
    required this.category,
    this.initialWorkout,
    this.editingStorageKey,
  });

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _nameController = TextEditingController(text: 'My Workout');
  final _noteController = TextEditingController();

  final List<WorkoutExerciseEntry> _entries = [];
  final List<WarmupCooldownItem> _warmups = [];
  final List<WarmupCooldownItem> _cooldowns = [];

  // Default rest for new sets (seconds)
  int _defaultRest = 90;

  WorkoutCategory get cat => widget.category;

  @override
  void initState() {
    super.initState();
    if (widget.initialWorkout != null) {
      _applyWorkout(widget.initialWorkout!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _applyWorkout(Workout workout) {
    _nameController.text = workout.name;
    _noteController.text = workout.note ?? '';

    _entries
      ..clear()
      ..addAll(workout.exercises.map(_cloneEntry));
    _warmups
      ..clear()
      ..addAll(workout.warmups.map(_cloneWarmupCooldown));
    _cooldowns
      ..clear()
      ..addAll(workout.cooldowns.map(_cloneWarmupCooldown));
  }

  WorkoutExerciseEntry _cloneEntry(WorkoutExerciseEntry entry) {
    return WorkoutExerciseEntry(
      exercise: Exercise(
        id: entry.exercise.id,
        name: entry.exercise.name,
        primaryMuscle: entry.exercise.primaryMuscle,
        secondaryMuscles: List.of(entry.exercise.secondaryMuscles),
      ),
      equipment: entry.equipment
          .map(
            (e) => Equipment(
              id: e.id,
              name: e.name,
              category: e.category,
            ),
          )
          .toList(),
      sets: entry.sets
          .map(
            (s) => WorkoutSet(
              reps: s.reps,
              weightKg: s.weightKg,
              durationSeconds: s.durationSeconds,
              tempoEccentric: s.tempoEccentric,
              tempoPause1: s.tempoPause1,
              tempoConcentric: s.tempoConcentric,
              tempoPause2: s.tempoPause2,
              distanceKm: s.distanceKm,
              calories: s.calories,
              rpe: s.rpe,
              restSeconds: s.restSeconds,
              note: s.note,
            ),
          )
          .toList(),
      note: entry.note,
      exerciseDurationSeconds: entry.exerciseDurationSeconds,
      restAfterExerciseSeconds: entry.restAfterExerciseSeconds,
    );
  }

  WarmupCooldownItem _cloneWarmupCooldown(WarmupCooldownItem item) {
    return WarmupCooldownItem(
      id: item.id,
      name: item.name,
      type: item.type,
      category: item.category,
    );
  }

  Future<void> _createFromExisting() async {
    final selected = await Navigator.of(context).push<Workout>(
      MaterialPageRoute(
        builder: (_) => ExistingWorkoutsScreen(currentCategory: cat),
      ),
    );
    if (!mounted || selected == null) return;

    if (selected.category != cat) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CreateWorkoutScreen(
            category: selected.category,
            initialWorkout: selected,
          ),
        ),
      );
      return;
    }

    setState(() {
      _applyWorkout(selected);
    });
  }

  // ── SAVE ────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise.')),
      );
      return;
    }
    final workout = Workout(
      storageKey: widget.editingStorageKey,
      name: _nameController.text.trim().isEmpty ? 'My Workout' : _nameController.text.trim(),
      category: cat,
      exercises: _entries
          .map(
            (entry) => WorkoutExerciseEntry(
              exercise: entry.exercise,
              equipment: entry.equipment,
              sets: entry.sets,
              note: entry.note,
              exerciseDurationSeconds: entry.exerciseDurationSeconds,
              restAfterExerciseSeconds: null,
            ),
          )
          .toList(),
      warmups: _warmups,
      cooldowns: _cooldowns,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      createdAt: widget.editingStorageKey != null
          ? (widget.initialWorkout?.createdAt ?? DateTime.now())
          : DateTime.now(),
    );
    await WorkoutStorage.instance.saveWorkout(workout);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.editingStorageKey != null ? 'Workout updated!' : 'Workout saved!',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '"${workout.name}" — ${_entries.length} exercise(s), '
          '${_warmups.length} warm-up(s), ${_cooldowns.length} cool-down(s).',
          style: const TextStyle(color: _subtle),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
  }

  // ── PICK EXERCISE ────────────────────────────────────────────────────────────

  Future<void> _pickExercise() async {
    final picked = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExercisePickerSheet(),
    );
    if (picked == null) return;
    setState(() {
      _entries.add(WorkoutExerciseEntry(exercise: picked));
    });
  }

  // ── PICK EQUIPMENT ───────────────────────────────────────────────────────────

  Future<void> _pickEquipment(WorkoutExerciseEntry entry) async {
    final picked = await showModalBottomSheet<List<Equipment>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EquipmentPickerSheet(selected: List.of(entry.equipment)),
    );
    if (picked == null) return;
    setState(() => entry.equipment = picked);
  }

  // ── PICK WARMUP / COOLDOWN ───────────────────────────────────────────────────

  Future<void> _pickWarmupCooldown({required bool isWarmup}) async {
    final current = isWarmup ? _warmups : _cooldowns;
    final picked = await showModalBottomSheet<List<WarmupCooldownItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WarmupCooldownPickerSheet(
        selected: List.of(current),
        filterType:
            isWarmup ? WarmupCooldownType.warmup : WarmupCooldownType.cooldown,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isWarmup) {
        _warmups
          ..clear()
          ..addAll(picked);
      } else {
        _cooldowns
          ..clear()
          ..addAll(picked);
      }
    });
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Workout',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              cat.shortName,
              style: const TextStyle(color: _accent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
        children: [
          _Section(
            child: Row(
              children: [
                Expanded(
                  child: _OutlinedAddButton(
                    label: 'Create From Existing Workout',
                    onTap: _createFromExisting,
                  ),
                ),
              ],
            ),
          ),

          // ── Name ──────────────────────────────────────────────────────────
          _Section(
            child: _LabeledField(
              label: 'Workout Name',
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: _inputDeco('e.g. Push Day'),
              ),
            ),
          ),

          // ── Warm-ups ──────────────────────────────────────────────────────
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionTitle(
                      icon: Icons.whatshot,
                      color: const Color(0xFFFFB74D),
                      label: 'Warm-Up',
                      badge: _warmups.isEmpty ? null : '${_warmups.length}',
                    ),
                    _ChipButton(
                      label: _warmups.isEmpty ? 'Add' : 'Edit',
                      onTap: () => _pickWarmupCooldown(isWarmup: true),
                    ),
                  ],
                ),
                if (_warmups.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._warmups.map((w) => _TagChip(label: w.name, color: const Color(0xFFFFB74D))),
                ],
              ],
            ),
          ),

          // ── Exercises ─────────────────────────────────────────────────────
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  icon: Icons.fitness_center,
                  color: _accent,
                  label: 'Exercises',
                  badge: _entries.isEmpty ? null : '${_entries.length}',
                ),
                const SizedBox(height: 10),
                if (_entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'No exercises yet. Tap "Add Exercise" below.',
                      style: const TextStyle(color: _dimmer, fontSize: 13),
                    ),
                  ),
                if (_entries.isNotEmpty)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: _entries.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final moved = _entries.removeAt(oldIndex);
                        _entries.insert(newIndex, moved);
                      });
                    },
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _ExerciseCard(
                        key: ValueKey('${entry.exercise.id}_$index'),
                        index: index,
                        entry: entry,
                        category: cat,
                        defaultRest: _defaultRest,
                        onRemove: () => setState(() => _entries.removeAt(index)),
                        onPickEquipment: () => _pickEquipment(entry),
                        onChanged: () => setState(() {}),
                      );
                    },
                  ),
                const SizedBox(height: 6),
                _OutlinedAddButton(label: 'Add Exercise', onTap: _pickExercise),
              ],
            ),
          ),

          // ── Cool-downs ────────────────────────────────────────────────────
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionTitle(
                      icon: Icons.ac_unit,
                      color: const Color(0xFF4FC3F7),
                      label: 'Cool-Down',
                      badge: _cooldowns.isEmpty ? null : '${_cooldowns.length}',
                    ),
                    _ChipButton(
                      label: _cooldowns.isEmpty ? 'Add' : 'Edit',
                      onTap: () => _pickWarmupCooldown(isWarmup: false),
                    ),
                  ],
                ),
                if (_cooldowns.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._cooldowns.map((c) => _TagChip(label: c.name, color: const Color(0xFF4FC3F7))),
                ],
              ],
            ),
          ),

          // ── Notes ─────────────────────────────────────────────────────────
          _Section(
            child: _LabeledField(
              label: 'Notes (optional)',
              child: TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                decoration: _inputDeco('Add any notes about this workout…'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final int index;
  final WorkoutExerciseEntry entry;
  final WorkoutCategory category;
  final int defaultRest;
  final VoidCallback onRemove;
  final VoidCallback onPickEquipment;
  final VoidCallback onChanged;

  const _ExerciseCard({
    super.key,
    required this.index,
    required this.entry,
    required this.category,
    required this.defaultRest,
    required this.onRemove,
    required this.onPickEquipment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _accent.withAlpha(38),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: _accent, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _muscleIcon(entry.exercise.primaryMuscle),
                            color: _accent,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.exercise.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        entry.exercise.primaryMuscle.displayName,
                        style: const TextStyle(color: _subtle, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: IconButton(
                    icon: const Icon(Icons.open_with, color: _accent, size: 18),
                    onPressed: null,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: _dimmer, size: 18),
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Equipment row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: GestureDetector(
              onTap: onPickEquipment,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.handyman, color: _subtle, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      entry.equipment.isEmpty
                          ? 'Add equipment / weights'
                          : entry.equipment.map((e) => e.name).join(', '),
                      style: TextStyle(
                        color: entry.equipment.isEmpty ? _dimmer : _subtle,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: _dimmer, size: 14),
                  ],
                ),
              ),
            ),
          ),

          // Time-based: exercise duration (optional per-exercise override)
          if (category == WorkoutCategory.timeBased) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: _accent, size: 14),
                  const SizedBox(width: 6),
                  const Text('Exercise duration:', style: TextStyle(color: _subtle, fontSize: 12)),
                  const SizedBox(width: 8),
                  _RestPicker(
                    value: entry.exerciseDurationSeconds ?? 60,
                    onChanged: (v) {
                      entry.exerciseDurationSeconds = v;
                      onChanged();
                    },
                    label: '',
                  ),
                ],
              ),
            ),
          ],

          // Sets table
          _SetsTable(
            entry: entry,
            category: category,
            defaultRest: defaultRest,
            onChanged: onChanged,
          ),

          // Add set
          TextButton.icon(
            onPressed: () {
              final prev = entry.sets.isEmpty ? null : entry.sets.last;
              entry.sets.add(WorkoutSet(
                reps: prev?.reps,
                weightKg: prev?.weightKg,
                durationSeconds: prev?.durationSeconds ?? 60,
                distanceKm: prev?.distanceKm,
                rpe: prev?.rpe,
                restSeconds: prev?.restSeconds ?? defaultRest,
              ));
              onChanged();
            },
            icon: const Icon(Icons.add, color: _accent, size: 16),
            label: const Text('Add set', style: TextStyle(color: _accent, fontSize: 13)),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
            ),
          ),

          // Exercise note
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: _inputDeco('Notes…').copyWith(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              onChanged: (v) => entry.note = v.isEmpty ? null : v,
              controller: TextEditingController(text: entry.note)
                ..selection = TextSelection.collapsed(offset: entry.note?.length ?? 0),
            ),
          ),

        ],
      ),
    );
  }
}

// ── Sets table ────────────────────────────────────────────────────────────────

class _SetsTable extends StatelessWidget {
  final WorkoutExerciseEntry entry;
  final WorkoutCategory category;
  final int defaultRest;
  final VoidCallback onChanged;

  const _SetsTable({
    required this.entry,
    required this.category,
    required this.defaultRest,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (entry.sets.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: _buildHeaderCells()),
          ),
          // Set rows
          ...entry.sets.asMap().entries.map(
            (e) => _SetRow(
              setIndex: e.key,
              set_: e.value,
              category: category,
              isLastSet: e.key == entry.sets.length - 1,
              onRemove: entry.sets.length > 1
                  ? () {
                      entry.sets.removeAt(e.key);
                      onChanged();
                    }
                  : null,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderCells() {
    const style = TextStyle(color: _subtle, fontSize: 11, fontWeight: FontWeight.w600);
    final cells = <Widget>[
      const SizedBox(width: 28, child: Text('Set', style: style, textAlign: TextAlign.center)),
      const SizedBox(width: 8),
    ];

    switch (category) {
      case WorkoutCategory.repBased:
        cells.addAll([
          _headerCell('Reps', style, icon: Icons.repeat_rounded),
          const SizedBox(width: 4),
          _headerCell('Weight (kg)', style, icon: Icons.fitness_center_rounded),
          const SizedBox(width: 4),
          _headerCell('Rest', style, icon: Icons.timer_outlined),
        ]);
        break;
      case WorkoutCategory.timeBased:
        cells.addAll([
          const Expanded(child: Text('Duration', style: style, textAlign: TextAlign.center)),
          const SizedBox(width: 4),
          _headerCell('Weight (kg)', style, icon: Icons.fitness_center_rounded),
          const SizedBox(width: 4),
          _headerCell('Rest', style, icon: Icons.timer_outlined),
        ]);
        break;
      case WorkoutCategory.tut:
        cells.addAll([
          _headerCell('Reps', style, icon: Icons.repeat_rounded),
          const SizedBox(width: 4),
          const Expanded(child: Text('Tempo', style: style, textAlign: TextAlign.center)),
          const SizedBox(width: 4),
          _headerCell('Wt (kg)', style, icon: Icons.fitness_center_rounded),
          const SizedBox(width: 4),
          _headerCell('Rest', style, icon: Icons.timer_outlined),
        ]);
        break;
      case WorkoutCategory.distanceCalorieRpe:
        cells.addAll([
          const Expanded(child: Text('Dist (km)', style: style, textAlign: TextAlign.center)),
          const SizedBox(width: 4),
          const Expanded(child: Text('Cal', style: style, textAlign: TextAlign.center)),
          const SizedBox(width: 4),
          const Expanded(child: Text('RPE', style: style, textAlign: TextAlign.center)),
          const SizedBox(width: 4),
          const Expanded(child: Text('Rest', style: style, textAlign: TextAlign.center)),
        ]);
        break;
    }
    cells.add(const SizedBox(width: 28)); // delete icon placeholder
    return cells;
  }

  Widget _headerCell(String label, TextStyle style, {IconData? icon}) {
    if (icon == null) {
      return Expanded(child: Text(label, style: style, textAlign: TextAlign.center));
    }
    return Expanded(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: _subtle),
            const SizedBox(width: 3),
            Text(label, style: style),
          ],
        ),
      ),
    );
  }
}

// ── Single set row ────────────────────────────────────────────────────────────

class _SetRow extends StatefulWidget {
  final int setIndex;
  final WorkoutSet set_;
  final WorkoutCategory category;
  final bool isLastSet;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _SetRow({
    required this.setIndex,
    required this.set_,
    required this.category,
    required this.isLastSet,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Set number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${widget.setIndex + 1}',
                style: const TextStyle(color: _subtle, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ..._buildCells(),
          // Delete button
          SizedBox(
            width: 28,
            child: widget.onRemove != null
                ? GestureDetector(
                    onTap: widget.onRemove,
                    child: const Icon(Icons.remove_circle_outline, color: _dimmer, size: 16),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCells() {
    switch (widget.category) {
      case WorkoutCategory.repBased:
        return [
          Expanded(child: _repsCell()),
          const SizedBox(width: 4),
          Expanded(child: _weightCell()),
          const SizedBox(width: 4),
          Expanded(child: _restCell()),
        ];
      case WorkoutCategory.timeBased:
        return [
          Expanded(child: _durationCell()),
          const SizedBox(width: 4),
          Expanded(child: _weightCell()),
          const SizedBox(width: 4),
          Expanded(child: _restCell()),
        ];
      case WorkoutCategory.tut:
        return [
          Expanded(child: _repsCell()),
          const SizedBox(width: 4),
          Expanded(child: _tempoCell()),
          const SizedBox(width: 4),
          Expanded(child: _weightCell()),
          const SizedBox(width: 4),
          Expanded(child: _restCell()),
        ];
      case WorkoutCategory.distanceCalorieRpe:
        return [
          Expanded(child: _distanceCell()),
          const SizedBox(width: 4),
          Expanded(child: _caloriesCell()),
          const SizedBox(width: 4),
          Expanded(child: _rpeCell()),
          const SizedBox(width: 4),
          Expanded(child: _restCell()),
        ];
    }
  }

  Widget _repsCell() => _TappableCell(
        label: widget.set_.reps?.toString() ?? 'Max',
        onTap: () => _pickReps(),
      );

  Widget _weightCell() => _NumericCell(
        value: widget.set_.weightKg?.toString() ?? '',
        hint: '—',
        decimal: true,
        onChanged: (v) {
          widget.set_.weightKg = double.tryParse(v);
          widget.onChanged();
        },
      );

  Widget _durationCell() => _TappableCell(
        label: _fmtSeconds(widget.set_.durationSeconds ?? 60),
        onTap: () => _pickDuration(
          initial: widget.set_.durationSeconds ?? 60,
          title: 'Set Duration',
          onPicked: (v) {
            widget.set_.durationSeconds = v;
            widget.onChanged();
          },
        ),
      );

  Widget _tempoCell() {
    final e = widget.set_.tempoEccentric ?? 3;
    final p1 = widget.set_.tempoPause1 ?? 1;
    final c = widget.set_.tempoConcentric ?? 1;
    final p2 = widget.set_.tempoPause2 ?? 0;
    return _TappableCell(
      label: '$e-$p1-$c-$p2',
      onTap: () => _pickTempo(),
    );
  }

  Widget _distanceCell() => _NumericCell(
        value: widget.set_.distanceKm?.toString() ?? '',
        hint: '0.0',
        decimal: true,
        onChanged: (v) {
          widget.set_.distanceKm = double.tryParse(v);
          widget.onChanged();
        },
      );

  Widget _caloriesCell() => _NumericCell(
        value: widget.set_.calories?.toString() ?? '',
        hint: '—',
        onChanged: (v) {
          widget.set_.calories = int.tryParse(v);
          widget.onChanged();
        },
      );

  Widget _rpeCell() => _TappableCell(
        label: widget.set_.rpe != null ? '${widget.set_.rpe}' : '—',
        onTap: () => _pickRpe(),
      );

  Widget _restCell() => _TappableCell(
        label: _fmtTimeInputSeconds(widget.set_.restSeconds),
      backgroundColor: widget.isLastSet ? const Color.fromARGB(255, 12, 21, 26) : _surface,
        onTap: () => _pickDuration(
          initial: widget.set_.restSeconds,
          title: 'Rest After Set',
          onPicked: (v) {
            widget.set_.restSeconds = v;
            widget.onChanged();
          },
        ),
      );

  // ── Pickers ──────────────────────────────────────────────────────────────

  void _pickDuration({
    required int initial,
    required String title,
    required void Function(int) onPicked,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DurationPickerSheet(
        initial: initial,
        title: title,
        onPicked: (v) {
          setState(() => onPicked(v));
        },
      ),
    );
  }

  void _pickTempo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TempoPickerSheet(
        eccentric: widget.set_.tempoEccentric ?? 3,
        pause1: widget.set_.tempoPause1 ?? 1,
        concentric: widget.set_.tempoConcentric ?? 1,
        pause2: widget.set_.tempoPause2 ?? 0,
        onPicked: (e, p1, c, p2) {
          setState(() {
            widget.set_.tempoEccentric = e;
            widget.set_.tempoPause1 = p1;
            widget.set_.tempoConcentric = c;
            widget.set_.tempoPause2 = p2;
            widget.onChanged();
          });
        },
      ),
    );
  }

  void _pickRpe() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _RpePickerSheet(
        initial: widget.set_.rpe ?? 7,
        onPicked: (v) {
          setState(() {
            widget.set_.rpe = v;
            widget.onChanged();
          });
        },
      ),
    );
  }

  void _pickReps() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RepsPickerSheet(
        initial: widget.set_.reps ?? 0,
        initialCenterValue: widget.set_.reps,
        onPicked: (v) {
          setState(() {
            widget.set_.reps = v;
            widget.onChanged();
          });
        },
      ),
    );
  }
}

// ── Cell widgets ──────────────────────────────────────────────────────────────

class _NumericCell extends StatelessWidget {
  final String value;
  final String hint;
  final bool decimal;
  final ValueChanged<String> onChanged;

  const _NumericCell({
    required this.value,
    required this.hint,
    this.decimal = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: decimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _dimmer, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _TappableCell extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _TappableCell({
    required this.label,
    this.backgroundColor = _surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }
}

// ── Duration picker sheet ─────────────────────────────────────────────────────

class _DurationPickerSheet extends StatefulWidget {
  final int initial;
  final String title;
  final ValueChanged<int> onPicked;

  const _DurationPickerSheet({
    required this.initial,
    required this.title,
    required this.onPicked,
  });

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  late int _minutes;
  late int _seconds;
  List<int> _presets = [];
  final _activeChipKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _minutes = widget.initial ~/ 60;
    _seconds = widget.initial % 60;
    _presets = RestPresetStorage.instance.getPresets();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
  }

  void _scrollToActive() {
    final ctx = _activeChipKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  int get _currentSeconds => _minutes * 60 + _seconds;

  void _applyPreset(BuildContext context, int seconds) {
    RestPresetStorage.instance.saveLastUsed(seconds);
    widget.onPicked(seconds);
    Navigator.pop(context);
  }

  Future<void> _addToPreset() async {
    await RestPresetStorage.instance.addPreset(_currentSeconds);
    setState(() => _presets = RestPresetStorage.instance.getPresets());
  }

  Future<void> _removePreset(int seconds) async {
    await RestPresetStorage.instance.removePreset(seconds);
    setState(() => _presets = RestPresetStorage.instance.getPresets());
  }

  String _fmtPreset(int s) {
    if (s <= 0) return '0s';
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final rem = s % 60;
    return rem == 0 ? '${m}m' : '${m}m ${rem}s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final alreadySaved = _presets.contains(_currentSeconds);
    final activeChip = _currentSeconds;
    return Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ─────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _surface2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // ── Title + Add to Preset ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: alreadySaved ? null : _addToPreset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: alreadySaved ? _surface2 : _accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: alreadySaved ? _surface2 : _accent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          alreadySaved ? Icons.bookmark : Icons.bookmark_border,
                          color: alreadySaved ? _subtle : _accent,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alreadySaved ? 'Saved' : 'Add Preset',
                          style: TextStyle(
                            color: alreadySaved ? _subtle : _accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Preset chips ────────────────────────────────────────────────
            if (_presets.isNotEmpty)
              SizedBox(
                height: 36,
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.04, 0.96, 1.0],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: _presets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final s = _presets[i];
                      final active = s == activeChip;
                      return GestureDetector(
                        key: active ? _activeChipKey : null,
                        onTap: () => _applyPreset(context, s),
                        onLongPress: () => _removePreset(s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? _accent : _surface2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active ? _accent : _surface2,
                            ),
                          ),
                          child: Text(
                            _fmtPreset(s),
                            style: TextStyle(
                              color: active ? Colors.white : _subtle,
                              fontSize: 13,
                              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 14),
            // ── Spinners ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _SpinnerColumn(
                  label: 'MIN',
                  value: _minutes,
                  max: 59,
                  onChanged: (v) => setState(() => _minutes = v),
                )),
                const Text(':', style: TextStyle(color: Colors.white, fontSize: 32)),
                Expanded(child: _SpinnerColumn(
                  label: 'SEC',
                  value: _seconds,
                  max: 59,
                  onChanged: (v) => setState(() => _seconds = v),
                )),
              ],
            ),
            const SizedBox(height: 20),
            _AccentButton(
              label: 'Confirm',
              onTap: () {
                RestPresetStorage.instance.saveLastUsed(_currentSeconds);
                widget.onPicked(_currentSeconds);
                Navigator.pop(context);
              },
            ),
          ],
        ),
    );
  }
}

class _RepsPickerSheet extends StatefulWidget {
  final int initial;
  final int? initialCenterValue;
  final ValueChanged<int> onPicked;

  const _RepsPickerSheet({
    required this.initial,
    this.initialCenterValue,
    required this.onPicked,
  });

  @override
  State<_RepsPickerSheet> createState() => _RepsPickerSheetState();
}

class _RepsPickerSheetState extends State<_RepsPickerSheet> {
  final List<int> _quickValues = List<int>.generate(13, (i) => i);
  final ScrollController _quickScrollController = ScrollController();
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initial < 0 ? 0 : widget.initial;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final centerValue = widget.initialCenterValue;
      if (centerValue != null && centerValue >= 0 && centerValue <= _quickValues.last) {
        _centerQuickValue(centerValue);
      }
    });
  }

  void _centerQuickValue(int value) {
    if (!_quickScrollController.hasClients) return;
    const chipWidth = 30.0;
    const chipGap = 6.0;
    final viewport = _quickScrollController.position.viewportDimension;
    final targetCenter = value * (chipWidth + chipGap) + (chipWidth / 2);
    final targetOffset = (targetCenter - (viewport / 2)).clamp(
      0.0,
      _quickScrollController.position.maxScrollExtent,
    );
    _quickScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _quickScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final quickLeftOpacity = _quickScrollController.hasClients
        ? (_quickScrollController.position.pixels / 10.0).clamp(0.0, 1.0)
        : 0.0;
    final quickRightOpacity = _quickScrollController.hasClients
        ? ((_quickScrollController.position.maxScrollExtent -
                    _quickScrollController.position.pixels) /
                10.0)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _surface2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Set Reps',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Quick Select',
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (_) {
                    setState(() {});
                    return false;
                  },
                  child: ListView.separated(
                    controller: _quickScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickValues.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, i) {
                      final v = _quickValues[i];
                      final isSelected = v == _selectedValue;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedValue = v),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected ? const Color(0xFF2A6B52) : const Color(0xFF112026),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF59B38A)
                                  : const Color(0xFF22343B),
                            ),
                          ),
                          child: Text(
                            '$v',
                            style: TextStyle(
                              color: Colors.white.withAlpha(isSelected ? 255 : 210),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: quickLeftOpacity,
                      child: Container(
                        width: 10,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF152126), Color(0x00152126)],
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
                      opacity: quickRightOpacity,
                      child: Container(
                        width: 10,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [Color(0xFF152126), Color(0x00152126)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, color: _accent),
                onPressed: () => setState(() => _selectedValue += 1),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Text(
            _selectedValue.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: _accent),
                onPressed:
                    _selectedValue > 0 ? () => setState(() => _selectedValue -= 1) : null,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AccentButton(
            label: 'Confirm',
            onTap: () {
              widget.onPicked(_selectedValue);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── Tempo picker sheet ────────────────────────────────────────────────────────

class _TempoPickerSheet extends StatefulWidget {
  final int eccentric, pause1, concentric, pause2;
  final void Function(int, int, int, int) onPicked;

  const _TempoPickerSheet({
    required this.eccentric,
    required this.pause1,
    required this.concentric,
    required this.pause2,
    required this.onPicked,
  });

  @override
  State<_TempoPickerSheet> createState() => _TempoPickerSheetState();
}

class _TempoPickerSheetState extends State<_TempoPickerSheet> {
  late int _e, _p1, _c, _p2;

  @override
  void initState() {
    super.initState();
    _e = widget.eccentric;
    _p1 = widget.pause1;
    _c = widget.concentric;
    _p2 = widget.pause2;
  }

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'Tempo (E – P1 – C – P2)',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Eccentric · Pause · Concentric · Pause',
            style: TextStyle(color: _subtle, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _SpinnerColumn(label: 'Ecc', value: _e, max: 10, onChanged: (v) => setState(() => _e = v))),
              Expanded(child: _SpinnerColumn(label: 'P1', value: _p1, max: 10, onChanged: (v) => setState(() => _p1 = v))),
              Expanded(child: _SpinnerColumn(label: 'Con', value: _c, max: 10, onChanged: (v) => setState(() => _c = v))),
              Expanded(child: _SpinnerColumn(label: 'P2', value: _p2, max: 10, onChanged: (v) => setState(() => _p2 = v))),
            ],
          ),
          const SizedBox(height: 20),
          _AccentButton(
            label: 'Confirm  $_e – $_p1 – $_c – $_p2',
            onTap: () {
              widget.onPicked(_e, _p1, _c, _p2);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── RPE picker sheet ──────────────────────────────────────────────────────────

class _RpePickerSheet extends StatefulWidget {
  final int initial;
  final ValueChanged<int> onPicked;

  const _RpePickerSheet({required this.initial, required this.onPicked});

  @override
  State<_RpePickerSheet> createState() => _RpePickerSheetState();
}

class _RpePickerSheetState extends State<_RpePickerSheet> {
  late int _value;
  static const _labels = {
    1: 'Very Easy', 2: 'Easy', 3: 'Moderate', 4: 'Somewhat Hard',
    5: 'Hard', 6: 'Hard+', 7: 'Very Hard', 8: 'Very Hard+',
    9: 'Near Max', 10: 'Max Effort',
  };

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'RPE (Rate of Perceived Exertion)',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RPE $_value — ${_labels[_value]}',
            style: const TextStyle(color: _accent, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: _accent,
            inactiveColor: _surface2,
            onChanged: (v) => setState(() => _value = v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1', style: TextStyle(color: _subtle, fontSize: 11)),
              Text('10', style: TextStyle(color: _subtle, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          _AccentButton(
            label: 'Confirm  RPE $_value',
            onTap: () {
              widget.onPicked(_value);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── Spinner column (shared by pickers) ───────────────────────────────────────

class _SpinnerColumn extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _SpinnerColumn({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: _subtle, fontSize: 11)),
        const SizedBox(height: 4),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, color: _accent),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: _accent),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

// ── Rest picker (inline) ──────────────────────────────────────────────────────

class _RestPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  const _RestPicker({required this.value, required this.onChanged, this.label = 'Rest'});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _DurationPickerSheet(
          initial: value,
          title: label.isNotEmpty ? label : 'Rest Duration',
          onPicked: onChanged,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, color: _accent, size: 14),
            const SizedBox(width: 4),
            Text(_fmtTimeInputSeconds(value), style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── Exercise picker sheet ─────────────────────────────────────────────────────

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet();

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final all = ExerciseRepository.instance.exercises;
    final filtered = _query.isEmpty
        ? all
        : all.where((e) => e.name.toLowerCase().contains(_query)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final list = _query.isEmpty
        ? (List.of(all)..sort((a, b) => a.name.compareTo(b.name)))
        : filtered;

    return _Sheet(
      title: 'Select Exercise',
      heightFactor: 0.85,
      child: Column(
        children: [
          TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDeco('Search exercises…'),
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final ex = list[i];
                return ListTile(
                  dense: true,
                  title: Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(ex.primaryMuscle.displayName,
                      style: const TextStyle(color: _subtle, fontSize: 12)),
                  onTap: () => Navigator.of(context).pop(ex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Equipment picker sheet ────────────────────────────────────────────────────

class _EquipmentPickerSheet extends StatefulWidget {
  final List<Equipment> selected;
  const _EquipmentPickerSheet({required this.selected});

  @override
  State<_EquipmentPickerSheet> createState() => _EquipmentPickerSheetState();
}

class _EquipmentPickerSheetState extends State<_EquipmentPickerSheet> {
  late List<Equipment> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final all = EquipmentRepository.instance.equipment;
    final list = _query.isEmpty
        ? (List.of(all)..sort((a, b) => a.name.compareTo(b.name)))
        : (all.where((e) => e.name.toLowerCase().contains(_query)).toList()
          ..sort((a, b) => a.name.compareTo(b.name)));

    return _Sheet(
      title: 'Select Equipment',
      heightFactor: 0.8,
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDeco('Search equipment…'),
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final eq = list[i];
                final checked = _selected.any((s) => s.id == eq.id);
                return CheckboxListTile(
                  dense: true,
                  value: checked,
                  activeColor: _accent,
                  checkColor: Colors.white,
                  title: Text(eq.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(eq.category.displayName,
                      style: const TextStyle(color: _subtle, fontSize: 12)),
                  onChanged: (_) => setState(() {
                    if (checked) {
                      _selected.removeWhere((s) => s.id == eq.id);
                    } else {
                      _selected.add(eq);
                    }
                  }),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _AccentButton(
              label: _selected.isEmpty ? 'Confirm (none)' : 'Confirm (${_selected.length})',
              onTap: () => Navigator.of(context).pop(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Warmup/Cooldown picker sheet ──────────────────────────────────────────────

class _WarmupCooldownPickerSheet extends StatefulWidget {
  final List<WarmupCooldownItem> selected;
  final WarmupCooldownType filterType;

  const _WarmupCooldownPickerSheet({
    required this.selected,
    required this.filterType,
  });

  @override
  State<_WarmupCooldownPickerSheet> createState() =>
      _WarmupCooldownPickerSheetState();
}

class _WarmupCooldownPickerSheetState
    extends State<_WarmupCooldownPickerSheet> {
  late List<WarmupCooldownItem> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final all = WarmupCooldownRepository.instance.items
        .where((i) => i.type == widget.filterType || i.type == WarmupCooldownType.both)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final list = _query.isEmpty
        ? all
        : all.where((e) => e.name.toLowerCase().contains(_query)).toList();

    final title = widget.filterType == WarmupCooldownType.warmup
        ? 'Select Warm-Up'
        : 'Select Cool-Down';

    return _Sheet(
      title: title,
      heightFactor: 0.8,
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDeco('Search…'),
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final item = list[i];
                final checked = _selected.any((s) => s.id == item.id);
                return CheckboxListTile(
                  dense: true,
                  value: checked,
                  activeColor: _accent,
                  checkColor: Colors.white,
                  title: Text(item.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(item.category.displayName,
                      style: const TextStyle(color: _subtle, fontSize: 12)),
                  onChanged: (_) => setState(() {
                    if (checked) {
                      _selected.removeWhere((s) => s.id == item.id);
                    } else {
                      _selected.add(item);
                    }
                  }),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _AccentButton(
              label: _selected.isEmpty ? 'Confirm (none)' : 'Confirm (${_selected.length})',
              onTap: () => Navigator.of(context).pop(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared layout primitives ──────────────────────────────────────────────────

class _Sheet extends StatelessWidget {
  final String title;
  final Widget child;
  final double heightFactor;

  const _Sheet({
    required this.title,
    required this.child,
    this.heightFactor = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: heightFactor,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _surface2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? badge;

  const _SectionTitle({
    required this.icon,
    required this.color,
    required this.label,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        if (badge != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(badge!,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: _subtle, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ChipButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _accent.withAlpha(38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: _subtle, fontSize: 12)),
        ],
      ),
    );
  }
}

class _OutlinedAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedAddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _accent.withAlpha(100)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: _accent, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: _accent, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AccentButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ),
    );
  }
}

InputDecoration _inputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _dimmer, fontSize: 13),
      filled: true,
      fillColor: _surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
