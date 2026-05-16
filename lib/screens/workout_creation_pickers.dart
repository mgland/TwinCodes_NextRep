import 'package:flutter/material.dart';

import '../data/equipment_repository.dart';
import '../data/exercise_repository.dart';
import '../data/warmup_cooldown_repository.dart';
import '../models/equipment.dart';
import '../models/exercise.dart';
import '../models/warmup_cooldown.dart';

const _pSurface = Color(0xFF152126);
const _pSurface2 = Color(0xFF1E2E33);
const _pAccent = Color(0xFF2A9D8F);
const _pSubtle = Color(0xFF8A9BA8);
const _pDim = Color(0xFF566A72);

class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({super.key});

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  static int _rememberedMode = 0; // 0 all, 1 by muscle, 2 favorites

  String _query = '';
  late int _mode;

  @override
  void initState() {
    super.initState();
    _mode = _rememberedMode;
  }

  void _setMode(int index) {
    setState(() {
      _mode = index;
      _rememberedMode = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = ExerciseRepository.instance.exercises;
    final filtered = _query.isEmpty
        ? List<Exercise>.of(all)
        : all.where((e) => e.name.toLowerCase().contains(_query)).toList();
    filtered.sort((a, b) => a.name.compareTo(b.name));

    final favorites = filtered.where((e) => e.isFavorite).toList();

    return _PickerSheetFrame(
      title: 'Select Exercise',
      heightFactor: 0.88,
      child: Column(
        children: [
          TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: _pickerInputDeco('Search exercises...'),
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          ),
          const SizedBox(height: 10),
          _ModeTabs(
            labels: const ['ALL', 'BY MUSCLE', 'FAVORITES'],
            selected: _mode,
            onSelect: _setMode,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _mode == 0
                ? _buildExerciseList(filtered)
                : _mode == 1
                    ? _buildExerciseByMuscle(filtered)
                    : _buildExerciseList(favorites, emptyText: 'No favorites found'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseByMuscle(List<Exercise> source) {
    if (source.isEmpty) {
      return const Center(
        child: Text('No exercises found', style: TextStyle(color: _pSubtle, fontSize: 14)),
      );
    }

    final map = <MuscleGroup, List<Exercise>>{};
    for (final ex in source) {
      map.putIfAbsent(ex.primaryMuscle, () => []).add(ex);
    }

    final groups = map.keys.toList()..sort((a, b) => a.displayName.compareTo(b.displayName));

    return ListView(
      children: groups
          .expand((m) => [
                _GroupHeader(title: m.displayName),
                ...map[m]!.map((ex) => _exerciseTile(ex)),
              ])
          .toList(),
    );
  }

  Widget _buildExerciseList(List<Exercise> list, {String emptyText = 'No exercises found'}) {
    if (list.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: _pSubtle, fontSize: 14)));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) => _exerciseTile(list[i]),
    );
  }

  Widget _exerciseTile(Exercise ex) {
    return ListTile(
      dense: true,
      leading: _IconBadge(icon: _muscleIcon(ex.primaryMuscle), color: _muscleColor(ex.primaryMuscle)),
      title: Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(ex.primaryMuscle.displayName, style: const TextStyle(color: _pSubtle, fontSize: 12)),
      trailing: IconButton(
        icon: Icon(ex.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: ex.isFavorite ? Colors.redAccent : _pDim, size: 20),
        onPressed: () => setState(() => ex.isFavorite = !ex.isFavorite),
      ),
      onTap: () => Navigator.of(context).pop(ex),
    );
  }
}

class EquipmentPickerSheet extends StatefulWidget {
  final List<Equipment> selected;

  const EquipmentPickerSheet({super.key, required this.selected});

  @override
  State<EquipmentPickerSheet> createState() => _EquipmentPickerSheetState();
}

class _EquipmentPickerSheetState extends State<EquipmentPickerSheet> {
  static int _rememberedMode = 0; // 0 all, 1 by category, 2 favorites

  late List<Equipment> _selected;
  String _query = '';
  late int _mode;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.selected);
    _mode = _rememberedMode;
  }

  void _setMode(int index) {
    setState(() {
      _mode = index;
      _rememberedMode = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = EquipmentRepository.instance.equipment;
    final filtered = _query.isEmpty
        ? List<Equipment>.of(all)
        : all.where((e) => e.name.toLowerCase().contains(_query)).toList();
    filtered.sort((a, b) => a.name.compareTo(b.name));

    final favorites = filtered.where((e) => e.isFavorite).toList();

    return _PickerSheetFrame(
      title: 'Select Equipment',
      heightFactor: 0.88,
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _pickerInputDeco('Search equipment...'),
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          ),
          const SizedBox(height: 10),
          _ModeTabs(
            labels: const ['ALL', 'BY CATEGORY', 'FAVORITES'],
            selected: _mode,
            onSelect: _setMode,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _mode == 0
                ? _buildEquipmentList(filtered)
                : _mode == 1
                    ? _buildEquipmentByCategory(filtered)
                    : _buildEquipmentList(favorites, emptyText: 'No favorites found'),
          ),
          const SizedBox(height: 10),
          _confirmButton(),
        ],
      ),
    );
  }

  Widget _confirmButton() {
    return _PrimaryButton(
      label: _selected.isEmpty ? 'Confirm (none)' : 'Confirm (${_selected.length})',
      onTap: () => Navigator.of(context).pop(_selected),
    );
  }

  Widget _buildEquipmentByCategory(List<Equipment> source) {
    if (source.isEmpty) {
      return const Center(
        child: Text('No equipment found', style: TextStyle(color: _pSubtle, fontSize: 14)),
      );
    }

    final map = <EquipmentCategory, List<Equipment>>{};
    for (final item in source) {
      map.putIfAbsent(item.category, () => []).add(item);
    }

    final groups = map.keys.toList()..sort((a, b) => a.displayName.compareTo(b.displayName));

    return ListView(
      children: groups
          .expand((c) => [
                _GroupHeader(title: c.displayName),
                ...map[c]!.map((eq) => _equipmentTile(eq)),
              ])
          .toList(),
    );
  }

  Widget _buildEquipmentList(List<Equipment> list, {String emptyText = 'No equipment found'}) {
    if (list.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: _pSubtle, fontSize: 14)));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) => _equipmentTile(list[i]),
    );
  }

  Widget _equipmentTile(Equipment eq) {
    final checked = _selected.any((s) => s.id == eq.id);
    return CheckboxListTile(
      dense: true,
      value: checked,
      activeColor: _pAccent,
      checkColor: Colors.white,
      secondary: _IconBadge(icon: _equipmentIcon(eq.category), color: _equipmentColor(eq.category)),
      title: Text(eq.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(eq.category.displayName, style: const TextStyle(color: _pSubtle, fontSize: 12)),
      onChanged: (_) => setState(() {
        if (checked) {
          _selected.removeWhere((s) => s.id == eq.id);
        } else {
          _selected.add(eq);
        }
      }),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

class WarmupCooldownPickerSheet extends StatefulWidget {
  final List<WarmupCooldownItem> selected;
  final WarmupCooldownType filterType;

  const WarmupCooldownPickerSheet({
    super.key,
    required this.selected,
    required this.filterType,
  });

  @override
  State<WarmupCooldownPickerSheet> createState() => _WarmupCooldownPickerSheetState();
}

class _WarmupCooldownPickerSheetState extends State<WarmupCooldownPickerSheet> {
  static int _rememberedMode = 0; // 0 all, 1 by type, 2 favorites

  late List<WarmupCooldownItem> _selected;
  String _query = '';
  late int _mode;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.selected);
    _mode = _rememberedMode;
  }

  void _setMode(int index) {
    setState(() {
      _mode = index;
      _rememberedMode = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.filterType == WarmupCooldownType.warmup
        ? 'Select Warm-Up'
        : 'Select Cool-Down';

    final all = WarmupCooldownRepository.instance.items
        .where((i) => i.type == widget.filterType || i.type == WarmupCooldownType.both)
        .toList();

    final filtered = _query.isEmpty
        ? List<WarmupCooldownItem>.of(all)
        : all.where((e) => e.name.toLowerCase().contains(_query)).toList();
    filtered.sort((a, b) => a.name.compareTo(b.name));

    final favorites = filtered.where((e) => e.isFavorite).toList();

    return _PickerSheetFrame(
      title: title,
      heightFactor: 0.88,
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _pickerInputDeco('Search...'),
            onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          ),
          const SizedBox(height: 10),
          _ModeTabs(
            labels: const ['ALL', 'BY TYPE', 'FAVORITES'],
            selected: _mode,
            onSelect: _setMode,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _mode == 0
                ? _buildItemList(filtered)
                : _mode == 1
                    ? _buildItemByType(filtered)
                    : _buildItemList(favorites, emptyText: 'No favorites found'),
          ),
          const SizedBox(height: 10),
          _PrimaryButton(
            label: _selected.isEmpty ? 'Confirm (none)' : 'Confirm (${_selected.length})',
            onTap: () => Navigator.of(context).pop(_selected),
          ),
        ],
      ),
    );
  }

  Widget _buildItemByType(List<WarmupCooldownItem> source) {
    if (source.isEmpty) {
      return const Center(
        child: Text('No items found', style: TextStyle(color: _pSubtle, fontSize: 14)),
      );
    }

    final map = <WarmupCooldownType, List<WarmupCooldownItem>>{};
    for (final item in source) {
      map.putIfAbsent(item.type, () => []).add(item);
    }

    final groups = map.keys.toList()..sort((a, b) => a.displayName.compareTo(b.displayName));

    return ListView(
      children: groups
          .expand((t) => [
                _GroupHeader(title: t.displayName),
                ...map[t]!.map((item) => _warmupTile(item)),
              ])
          .toList(),
    );
  }

  Widget _buildItemList(List<WarmupCooldownItem> list, {String emptyText = 'No items found'}) {
    if (list.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: _pSubtle, fontSize: 14)));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) => _warmupTile(list[i]),
    );
  }

  Widget _warmupTile(WarmupCooldownItem item) {
    final checked = _selected.any((s) => s.id == item.id);
    return CheckboxListTile(
      dense: true,
      value: checked,
      activeColor: _pAccent,
      checkColor: Colors.white,
      secondary: Stack(
        children: [
          _IconBadge(
            icon: _warmupIcon(item.category),
            color: _warmupColor(item.category),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _warmupTypeColor(item.type),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _warmupTypeIcon(item.type),
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      title: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(
        '${item.category.displayName} • ${item.type.displayName}',
        style: const TextStyle(color: _pSubtle, fontSize: 12),
      ),
      onChanged: (_) => setState(() {
        if (checked) {
          _selected.removeWhere((s) => s.id == item.id);
        } else {
          _selected.add(item);
        }
      }),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

class _PickerSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final double heightFactor;

  const _PickerSheetFrame({
    required this.title,
    required this.child,
    this.heightFactor = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: heightFactor,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            color: _pSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _pSurface2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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

class _ModeTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  const _ModeTabs({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: _pSurface2,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected ? _pAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : _pSubtle,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String title;

  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
      child: Text(
        title,
        style: const TextStyle(color: _pAccent, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withAlpha(45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _pAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

InputDecoration _pickerInputDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _pDim, fontSize: 13),
      filled: true,
      fillColor: _pSurface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );

IconData _muscleIcon(MuscleGroup m) {
  switch (m) {
    case MuscleGroup.chest:
      return Icons.fitness_center;
    case MuscleGroup.back:
      return Icons.accessibility_new;
    case MuscleGroup.shoulders:
      return Icons.sports_handball;
    case MuscleGroup.biceps:
      return Icons.sports_gymnastics;
    case MuscleGroup.triceps:
      return Icons.sports_gymnastics;
    case MuscleGroup.legs:
      return Icons.directions_walk;
    case MuscleGroup.core:
      return Icons.sports_martial_arts;
    case MuscleGroup.glutes:
      return Icons.directions_run;
    case MuscleGroup.calves:
      return Icons.directions_walk;
    case MuscleGroup.forearms:
      return Icons.back_hand;
    case MuscleGroup.fullBody:
      return Icons.person;
  }
}

Color _muscleColor(MuscleGroup m) {
  const map = {
    MuscleGroup.chest: Color(0xFF4FC3F7),
    MuscleGroup.back: Color(0xFF81C784),
    MuscleGroup.shoulders: Color(0xFFFFB74D),
    MuscleGroup.biceps: Color(0xFFE57373),
    MuscleGroup.triceps: Color(0xFFBA68C8),
    MuscleGroup.legs: Color(0xFF4DB6AC),
    MuscleGroup.core: Color(0xFFF06292),
    MuscleGroup.glutes: Color(0xFFFF8A65),
    MuscleGroup.calves: Color(0xFFA1887F),
    MuscleGroup.forearms: Color(0xFF90A4AE),
    MuscleGroup.fullBody: Color(0xFFFFD54F),
  };
  return map[m] ?? Colors.grey;
}

IconData _equipmentIcon(EquipmentCategory c) {
  switch (c) {
    case EquipmentCategory.freeWeights:
      return Icons.fitness_center;
    case EquipmentCategory.machines:
      return Icons.precision_manufacturing;
    case EquipmentCategory.cables:
      return Icons.cable;
    case EquipmentCategory.bodyweight:
      return Icons.accessibility_new;
    case EquipmentCategory.cardio:
      return Icons.directions_run;
    case EquipmentCategory.mobility:
      return Icons.self_improvement;
    case EquipmentCategory.accessories:
      return Icons.backpack;
    case EquipmentCategory.bars:
      return Icons.horizontal_rule;
    case EquipmentCategory.benches:
      return Icons.event_seat;
    case EquipmentCategory.racks:
      return Icons.grid_4x4;
  }
}

Color _equipmentColor(EquipmentCategory c) {
  const map = {
    EquipmentCategory.freeWeights: Color(0xFF4FC3F7),
    EquipmentCategory.machines: Color(0xFF81C784),
    EquipmentCategory.cables: Color(0xFFFFB74D),
    EquipmentCategory.bodyweight: Color(0xFFE57373),
    EquipmentCategory.cardio: Color(0xFFBA68C8),
    EquipmentCategory.mobility: Color(0xFF4DB6AC),
    EquipmentCategory.accessories: Color(0xFFF06292),
    EquipmentCategory.bars: Color(0xFFFF8A65),
    EquipmentCategory.benches: Color(0xFFA1887F),
    EquipmentCategory.racks: Color(0xFF90A4AE),
  };
  return map[c] ?? Colors.grey;
}

IconData _warmupIcon(WarmupCooldownCategory c) {
  switch (c) {
    case WarmupCooldownCategory.dynamicStretching:
      return Icons.accessibility_new;
    case WarmupCooldownCategory.staticStretching:
      return Icons.self_improvement;
    case WarmupCooldownCategory.foamRolling:
      return Icons.circle_outlined;
    case WarmupCooldownCategory.mobilityDrills:
      return Icons.rotate_right;
    case WarmupCooldownCategory.cardioWarmup:
      return Icons.directions_run;
    case WarmupCooldownCategory.activationDrills:
      return Icons.bolt;
    case WarmupCooldownCategory.breathing:
      return Icons.air;
    case WarmupCooldownCategory.balance:
      return Icons.balance;
  }
}

Color _warmupColor(WarmupCooldownCategory c) {
  const map = {
    WarmupCooldownCategory.dynamicStretching: Color(0xFFFFB74D),
    WarmupCooldownCategory.staticStretching: Color(0xFF4FC3F7),
    WarmupCooldownCategory.foamRolling: Color(0xFFBA68C8),
    WarmupCooldownCategory.mobilityDrills: Color(0xFF81C784),
    WarmupCooldownCategory.cardioWarmup: Color(0xFFE57373),
    WarmupCooldownCategory.activationDrills: Color(0xFFFF8A65),
    WarmupCooldownCategory.breathing: Color(0xFF4DB6AC),
    WarmupCooldownCategory.balance: Color(0xFFF06292),
  };
  return map[c] ?? Colors.grey;
}

IconData _warmupTypeIcon(WarmupCooldownType t) {
  switch (t) {
    case WarmupCooldownType.warmup:
      return Icons.whatshot;
    case WarmupCooldownType.cooldown:
      return Icons.ac_unit;
    case WarmupCooldownType.both:
      return Icons.sync;
  }
}

Color _warmupTypeColor(WarmupCooldownType t) {
  switch (t) {
    case WarmupCooldownType.warmup:
      return const Color(0xFFFFB74D);
    case WarmupCooldownType.cooldown:
      return const Color(0xFF4FC3F7);
    case WarmupCooldownType.both:
      return const Color(0xFF81C784);
  }
}
