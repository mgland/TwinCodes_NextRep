import 'package:flutter/material.dart';
import '../data/exercise_repository.dart';
import '../models/exercise.dart';

// ── Muscle group helpers ──────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen>
    with SingleTickerProviderStateMixin {
  // Heights used to compute scroll offsets for the alphabet index.
  static const double _headerHeight = 40.0;
  static const double _tileHeight = 76.0; // includes 2px vertical margin × 2

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _allScrollController = ScrollController();

  String _searchQuery = '';

  // ALL tab
  List<dynamic> _allFlatList = []; // String (letter) | Exercise
  Map<String, double> _letterOffsets = {};
  List<String> _availableLetters = [];

  // BY MUSCLE tab
  static const List<MuscleGroup> _muscleOrder = [
    MuscleGroup.chest,
    MuscleGroup.back,
    MuscleGroup.shoulders,
    MuscleGroup.biceps,
    MuscleGroup.triceps,
    MuscleGroup.legs,
    MuscleGroup.core,
    MuscleGroup.glutes,
    MuscleGroup.calves,
    MuscleGroup.forearms,
    MuscleGroup.fullBody,
  ];
  Map<MuscleGroup, List<Exercise>> _byMuscleMap = {};

  // FAVORITES tab
  List<Exercise> _favorites = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _rebuildLists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _allScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase().trim();
    if (q != _searchQuery) {
      setState(() {
        _searchQuery = q;
        _rebuildLists();
      });
    }
  }

  void _rebuildLists() {
    final all = ExerciseRepository.instance.exercises;
    final filtered = _searchQuery.isEmpty
        ? all
        : all
            .where((e) => e.name.toLowerCase().contains(_searchQuery))
            .toList();

    // ── ALL tab ────────────────────────────────────────────────────────────
    final sorted = [...filtered]..sort((a, b) => a.name.compareTo(b.name));
    _allFlatList = [];
    String currentLetter = '';
    for (final ex in sorted) {
      final letter = ex.name[0].toUpperCase();
      if (letter != currentLetter) {
        currentLetter = letter;
        _allFlatList.add(letter);
      }
      _allFlatList.add(ex);
    }

    // Compute scroll offsets for each letter header.
    _letterOffsets = {};
    double offset = 0;
    for (final item in _allFlatList) {
      if (item is String) {
        _letterOffsets[item] = offset;
        offset += _headerHeight;
      } else {
        offset += _tileHeight;
      }
    }
    _availableLetters = _letterOffsets.keys.toList()..sort();

    // ── BY MUSCLE tab ──────────────────────────────────────────────────────
    _byMuscleMap = {};
    for (final ex in filtered) {
      _byMuscleMap.putIfAbsent(ex.primaryMuscle, () => []).add(ex);
    }
    for (final list in _byMuscleMap.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    // ── FAVORITES tab ──────────────────────────────────────────────────────
    _favorites = all.where((e) => e.isFavorite).toList();
    if (_searchQuery.isNotEmpty) {
      _favorites = _favorites
          .where((e) => e.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
    _favorites.sort((a, b) => a.name.compareTo(b.name));
  }

  void _scrollToLetter(String letter) {
    final offset = _letterOffsets[letter];
    if (offset != null && _allScrollController.hasClients) {
      _allScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleFavorite(Exercise exercise) {
    setState(() {
      exercise.isFavorite = !exercise.isFavorite;
      _rebuildLists();
    });
  }

  int get _filteredCount {
    if (_searchQuery.isEmpty) {
      return ExerciseRepository.instance.exercises.length;
    }
    return ExerciseRepository.instance.exercises
        .where((e) => e.name.toLowerCase().contains(_searchQuery))
        .length;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B1E),
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text(
          'Add exercise',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _buildSearchBar(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _buildSegmentedTabBar(),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$_filteredCount exercises',
                style: const TextStyle(
                  color: Color(0xFF8A9BA8),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAllTab(),
                _buildByMuscleTab(),
                _buildFavoritesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search Exercises',
        hintStyle: const TextStyle(color: Color(0xFF8A9BA8)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF8A9BA8)),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Color(0xFF8A9BA8)),
                onPressed: () => _searchController.clear(),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1E2E33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSegmentedTabBar() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2E33),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              _buildTabItem(0, 'ALL'),
              _buildTabItem(1, 'BY MUSCLE'),
              _buildTabItem(2, 'FAVORITES'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF2A9D8F) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8A9BA8),
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── ALL tab ───────────────────────────────────────────────────────────────

  Widget _buildAllTab() {
    if (_allFlatList.isEmpty) {
      return _buildEmptyState('No exercises found');
    }
    return Stack(
      children: [
        ListView.builder(
          controller: _allScrollController,
          // Right padding leaves room for the alphabet index sidebar.
          padding: EdgeInsets.only(
            right: _searchQuery.isEmpty ? 28 : 0,
            bottom: 16,
          ),
          itemCount: _allFlatList.length,
          itemBuilder: (ctx, i) {
            final item = _allFlatList[i];
            if (item is String) return _buildLetterHeader(item);
            return _buildExerciseTile(item as Exercise);
          },
        ),
        if (_searchQuery.isEmpty)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildAlphabetIndex(),
          ),
      ],
    );
  }

  Widget _buildLetterHeader(String letter) {
    return Container(
      height: _headerHeight,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      color: const Color(0xFF0D1B1E),
      child: Text(
        letter,
        style: const TextStyle(
          color: Color(0xFF2A9D8F),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAlphabetIndex() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableLetters.map((letter) {
            return GestureDetector(
              onTap: () => _scrollToLetter(letter),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 1.5, horizontal: 6),
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Color(0xFF2A9D8F),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── BY MUSCLE tab ─────────────────────────────────────────────────────────

  Widget _buildByMuscleTab() {
    final groups =
        _muscleOrder.where((m) => _byMuscleMap.containsKey(m)).toList();
    if (groups.isEmpty) {
      return _buildEmptyState('No exercises found');
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: groups.length,
      itemBuilder: (ctx, i) {
        final muscle = groups[i];
        return _buildMuscleGroup(muscle, _byMuscleMap[muscle]!);
      },
    );
  }

  Widget _buildMuscleGroup(MuscleGroup muscle, List<Exercise> exercises) {
    final color = _muscleColor(muscle);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedBackgroundColor: const Color(0xFF0D1B1E),
        backgroundColor: const Color(0xFF0D1B1E),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_muscleIcon(muscle), color: color, size: 20),
        ),
        title: Row(
          children: [
            Text(
              muscle.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2E33),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${exercises.length}',
                style: const TextStyle(
                  color: Color(0xFF8A9BA8),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        iconColor: const Color(0xFF8A9BA8),
        collapsedIconColor: const Color(0xFF8A9BA8),
        children: exercises.map(_buildExerciseTile).toList(),
      ),
    );
  }

  // ── FAVORITES tab ─────────────────────────────────────────────────────────

  Widget _buildFavoritesTab() {
    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.white.withAlpha(51),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No favorites match your search'
                  : 'No favorites yet',
              style: const TextStyle(
                color: Color(0xFF8A9BA8),
                fontSize: 16,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap ♥ on any exercise to save it here',
                style: TextStyle(
                  color: Color(0xFF566A72),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _favorites.length,
      itemBuilder: (ctx, i) => _buildExerciseTile(_favorites[i]),
    );
  }

  // ── Shared exercise tile ──────────────────────────────────────────────────

  Widget _buildExerciseTile(Exercise exercise) {
    final color = _muscleColor(exercise.primaryMuscle);
    return Container(
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF152126),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Container(
              width: 68,
              color: Colors.white,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _muscleIcon(exercise.primaryMuscle),
                      size: 30,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  // Muscle colour badge (bottom-right corner)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          exercise.primaryMuscle.displayName[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Name + muscle label
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.primaryMuscle.displayName,
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          // Favourite toggle
          IconButton(
            icon: Icon(
              exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: exercise.isFavorite
                  ? Colors.redAccent
                  : const Color(0xFF566A72),
              size: 22,
            ),
            onPressed: () => _toggleFavorite(exercise),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 16),
      ),
    );
  }
}
