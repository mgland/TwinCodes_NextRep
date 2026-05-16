import 'package:flutter/material.dart';
import '../data/warmup_cooldown_repository.dart';
import '../models/warmup_cooldown.dart';

Color _typeColor(WarmupCooldownType t) {
  switch (t) {
    case WarmupCooldownType.warmup:
      return const Color(0xFFFFB74D);
    case WarmupCooldownType.cooldown:
      return const Color(0xFF4FC3F7);
    case WarmupCooldownType.both:
      return const Color(0xFF81C784);
  }
}

IconData _typeIcon(WarmupCooldownType t) {
  switch (t) {
    case WarmupCooldownType.warmup:
      return Icons.whatshot;
    case WarmupCooldownType.cooldown:
      return Icons.ac_unit;
    case WarmupCooldownType.both:
      return Icons.sync;
  }
}

Color _categoryColor(WarmupCooldownCategory c) {
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

IconData _categoryIcon(WarmupCooldownCategory c) {
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

class WarmupCooldownLibraryScreen extends StatefulWidget {
  const WarmupCooldownLibraryScreen({super.key});

  @override
  State<WarmupCooldownLibraryScreen> createState() =>
      _WarmupCooldownLibraryScreenState();
}

class _WarmupCooldownLibraryScreenState
    extends State<WarmupCooldownLibraryScreen>
    with SingleTickerProviderStateMixin {
  static const double _headerHeight = 40.0;
  static const double _tileHeight = 76.0;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _allScrollController = ScrollController();

  String _searchQuery = '';

  // ALL tab
  List<dynamic> _allFlatList = [];
  Map<String, double> _letterOffsets = {};
  List<String> _availableLetters = [];

  // BY TYPE tab
  static const List<WarmupCooldownType> _typeOrder = [
    WarmupCooldownType.warmup,
    WarmupCooldownType.cooldown,
    WarmupCooldownType.both,
  ];
  Map<WarmupCooldownType, List<WarmupCooldownItem>> _byTypeMap = {};

  // FAVORITES tab
  List<WarmupCooldownItem> _favorites = [];

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
    final all = WarmupCooldownRepository.instance.items;
    final filtered = _searchQuery.isEmpty
        ? all
        : all.where((e) => e.name.toLowerCase().contains(_searchQuery)).toList();

    // ── ALL tab ────────────────────────────────────────────────────────────
    final sorted = [...filtered]..sort((a, b) => a.name.compareTo(b.name));
    _allFlatList = [];
    String currentLetter = '';
    for (final item in sorted) {
      final letter = item.name[0].toUpperCase();
      if (letter != currentLetter) {
        currentLetter = letter;
        _allFlatList.add(letter);
      }
      _allFlatList.add(item);
    }

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

    // ── BY TYPE tab ────────────────────────────────────────────────────────
    _byTypeMap = {};
    for (final e in filtered) {
      _byTypeMap.putIfAbsent(e.type, () => []).add(e);
    }
    for (final list in _byTypeMap.values) {
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

  void _toggleFavorite(WarmupCooldownItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
      _rebuildLists();
    });
  }

  int get _filteredCount {
    if (_searchQuery.isEmpty) {
      return WarmupCooldownRepository.instance.items.length;
    }
    return WarmupCooldownRepository.instance.items
        .where((e) => e.name.toLowerCase().contains(_searchQuery))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B1E),
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: const Text(
          'Warm-Up & Cool-Down',
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
                '$_filteredCount items',
                style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 13),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAllTab(),
                _buildByTypeTab(),
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
        hintText: 'Search Warm-Up & Cool-Down',
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
              _buildTabItem(1, 'BY TYPE'),
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
            color: isSelected ? const Color(0xFF2A9D8F) : Colors.transparent,
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
      return _buildEmptyState('No items found');
    }
    return Stack(
      children: [
        ListView.builder(
          controller: _allScrollController,
          padding: EdgeInsets.only(
            right: _searchQuery.isEmpty ? 28 : 0,
            bottom: 16,
          ),
          itemCount: _allFlatList.length,
          itemBuilder: (ctx, i) {
            final item = _allFlatList[i];
            if (item is String) return _buildLetterHeader(item);
            return _buildItemTile(item as WarmupCooldownItem);
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
                padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 6),
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

  // ── BY TYPE tab ───────────────────────────────────────────────────────────

  Widget _buildByTypeTab() {
    final types = _typeOrder.where((t) => _byTypeMap.containsKey(t)).toList();
    if (types.isEmpty) {
      return _buildEmptyState('No items found');
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: types.length,
      itemBuilder: (ctx, i) {
        final type = types[i];
        return _buildTypeGroup(type, _byTypeMap[type]!);
      },
    );
  }

  Widget _buildTypeGroup(WarmupCooldownType type, List<WarmupCooldownItem> items) {
    final color = _typeColor(type);
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
          child: Icon(_typeIcon(type), color: color, size: 20),
        ),
        title: Row(
          children: [
            Text(
              type.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2E33),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${items.length}',
                style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 12),
              ),
            ),
          ],
        ),
        iconColor: const Color(0xFF8A9BA8),
        collapsedIconColor: const Color(0xFF8A9BA8),
        children: items.map(_buildItemTile).toList(),
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
            Icon(Icons.favorite_border,
                size: 64, color: Colors.white.withAlpha(51)),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No favorites match your search'
                  : 'No favorites yet',
              style: const TextStyle(color: Color(0xFF8A9BA8), fontSize: 16),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap ♥ on any item to save it here',
                style: TextStyle(color: Color(0xFF566A72), fontSize: 13),
              ),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _favorites.length,
      itemBuilder: (ctx, i) => _buildItemTile(_favorites[i]),
    );
  }

  // ── Shared tile ───────────────────────────────────────────────────────────

  Widget _buildItemTile(WarmupCooldownItem item) {
    final catColor = _categoryColor(item.category);
    final typeColor = _typeColor(item.type);
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
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Container(
              width: 68,
              color: Colors.white,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _categoryIcon(item.category),
                      size: 30,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  // Type badge (warm = flame colour, cool = blue)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                        ),
                      ),
                      child: Icon(
                        _typeIcon(item.type),
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Name + labels
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        item.category.displayName,
                        style: TextStyle(color: catColor, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withAlpha(38),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.type.displayName,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Favourite toggle
          IconButton(
            icon: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: item.isFavorite
                  ? Colors.redAccent
                  : const Color(0xFF566A72),
              size: 22,
            ),
            onPressed: () => _toggleFavorite(item),
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
