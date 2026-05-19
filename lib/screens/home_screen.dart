import 'dart:async';

import 'package:flutter/material.dart';

import '../data/workout_storage.dart';
import 'doing_workout_screen.dart';
import 'workouts_hub_screen.dart';

enum _NavTab {
  home,
  workouts,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _NavTab _current = _NavTab.home;
  _NavTab _previous = _NavTab.home;

  void _switchTab(_NavTab tab) {
    if (tab == _current) return;
    setState(() {
      _previous = _current;
      _current = tab;
    });
  }

  bool get _isForward => _current.index >= _previous.index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 460),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final offsetTween = Tween<Offset>(
                  begin: Offset(_isForward ? 0.12 : -0.12, 0.02),
                  end: Offset.zero,
                );
                final scaleTween = Tween<double>(begin: 0.96, end: 1.0);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(offsetTween),
                    child: ScaleTransition(
                      scale: animation.drive(scaleTween),
                      child: child,
                    ),
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_current.index),
                child: _buildPage(_current),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: Center(
              child: _FloatingNavGroup(
                current: _current,
                onTap: _switchTab,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_NavTab tab) {
    switch (tab) {
      case _NavTab.home:
        return const _HomeTab();
      case _NavTab.workouts:
        return const WorkoutsHubScreen();
    }
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  ActiveWorkoutSession? _activeSession;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadActiveSession();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _activeSession == null) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _loadActiveSession() {
    if (!mounted) return;
    setState(() {
      _activeSession = WorkoutStorage.instance.getActiveWorkoutSession();
    });
  }

  Future<void> _resumeWorkout() async {
    final session = _activeSession;
    if (session == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DoingWorkoutScreen(
          workout: session.workout,
          initialSession: session,
        ),
      ),
    );
    if (!mounted) return;
    _loadActiveSession();
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

  @override
  Widget build(BuildContext context) {
    final activeSession = _activeSession?.projectTo(DateTime.now());
    final completedCount = activeSession?.items.where((item) => item.done).length ?? 0;
    final totalCount = activeSession?.items.length ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
      children: [
        const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (activeSession != null) ...[
          GestureDetector(
            onTap: _resumeWorkout,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF19322D),
                    Color(0xFF152A25),
                    Color(0xFF0F211D),
                  ],
                ),
                border: Border.all(color: const Color(0xFF2A9D8F).withAlpha(140)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A9D8F).withAlpha(44),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Workout WIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF9CD0C7),
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeSession.workout.name,
                    style: const TextStyle(
                      color: Color(0xFFD8ECE7),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completedCount / $totalCount items complete  •  ${_fmtClock(activeSession.elapsedSeconds)} elapsed',
                    style: const TextStyle(
                      color: Color(0xFF9CC1B9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (activeSession.restSecondsRemaining > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Rest timer: ${_fmtClock(activeSession.restSecondsRemaining)}',
                      style: const TextStyle(
                        color: Color(0xFFB5E5D8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _FloatingNavGroup extends StatelessWidget {
  final _NavTab current;
  final ValueChanged<_NavTab> onTap;

  const _FloatingNavGroup({
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (tab: _NavTab.home, icon: Icons.home_rounded, label: 'HOME'),
      (tab: _NavTab.workouts, icon: Icons.grid_view_rounded, label: 'WORKOUTS'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2F39), Color(0xFF07303A)],
          ),
          border: Border.all(color: const Color(0xFF1C6574).withAlpha(150)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00B4D8).withAlpha(26),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tabs
              .map((item) => _FloatingNavItem(
                    icon: item.icon,
                    label: item.label,
                    selected: current == item.tab,
                    onTap: () => onTap(item.tab),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2A9D8F).withAlpha(60) : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(selected ? 14 : 12, 10, selected ? 14 : 12, 10),
            child: Row(
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  scale: selected ? 1.08 : 1.0,
                  child: Icon(
                    icon,
                    size: 21,
                    color: selected ? Colors.white : const Color(0xFF9CB6BE),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
