import 'package:flutter/material.dart';

import '../data/workout_storage.dart';
import '../models/workout.dart';

const _bg = Color(0xFF0D1B1E);
const _surface = Color(0xFF152126);
const _subtle = Color(0xFF8A9BA8);

class ExistingWorkoutsScreen extends StatefulWidget {
  final WorkoutCategory? currentCategory;

  const ExistingWorkoutsScreen({
    super.key,
    this.currentCategory,
  });

  @override
  State<ExistingWorkoutsScreen> createState() => _ExistingWorkoutsScreenState();
}

class _ExistingWorkoutsScreenState extends State<ExistingWorkoutsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Workout> _all = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _all = WorkoutStorage.instance.getAllWorkouts();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? _all
        : _all
            .where((w) => w.name.toLowerCase().contains(_query))
            .toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text(
          'Existing Workouts',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search workouts...',
                hintStyle: const TextStyle(color: _subtle),
                prefixIcon: const Icon(Icons.search, color: _subtle),
                filled: true,
                fillColor: _surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No saved workouts found',
                      style: TextStyle(color: _subtle, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final w = filtered[index];
                      final isDifferentCategory =
                          widget.currentCategory != null && widget.currentCategory != w.category;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: Material(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).pop(w),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          w.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      if (isDifferentCategory)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withAlpha(40),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'switch type',
                                            style: TextStyle(color: Colors.orange, fontSize: 11),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${w.category.shortName}  ·  ${w.exercises.length} exercises  ·  ${_fmtDate(w.createdAt)}',
                                    style: const TextStyle(color: _subtle, fontSize: 12),
                                  ),
                                  if ((w.note ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      w.note!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: _subtle, fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }
}
