import 'package:flutter/material.dart';

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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
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
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F3640),
                Color(0xFF0A2A34),
                Color(0xFF072129),
              ],
            ),
            border: Border.all(color: const Color(0xFF1B4D59).withAlpha(120)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buttons Removed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Navigation now lives in the floating button group below.\nTap Workouts to view and create workouts.',
                style: TextStyle(
                  color: Color(0xFF9AB8C2),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
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
