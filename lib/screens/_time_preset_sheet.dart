import 'package:flutter/material.dart';
import '../models/schedule.dart';

const _surface = Color(0xFF152126);
const _surface2 = Color(0xFF1E2E33);
const _accent = Color(0xFF2A9D8F);
const _subtle = Color(0xFF8A9BA8);
const _dimmer = Color(0xFF566A72);

class TimePresetSheet extends StatefulWidget {
  final WorkoutSchedule schedule;
  final Function(int, int) onPicked;

  const TimePresetSheet({
    required this.schedule,
    required this.onPicked,
  });

  @override
  State<TimePresetSheet> createState() => _TimePresetSheetState();
}

class _TimePresetSheetState extends State<TimePresetSheet> {
  late int _hour;
  late int _minute;

  final List<({int hour, int minute, String label})> _presets = [
    (hour: 6, minute: 0, label: '6:00 AM'),
    (hour: 9, minute: 0, label: '9:00 AM'),
    (hour: 12, minute: 0, label: '12:00 PM'),
    (hour: 15, minute: 0, label: '3:00 PM'),
    (hour: 18, minute: 0, label: '6:00 PM'),
    (hour: 20, minute: 0, label: '8:00 PM'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.schedule.scheduledTime != null) {
      _hour = widget.schedule.scheduledTime!.hour;
      _minute = widget.schedule.scheduledTime!.minute;
    } else {
      final now = DateTime.now();
      _hour = now.hour;
      _minute = now.minute;
    }
  }

  String _formatTime(int h, int m) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

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

          // ── Title ────────────────────────────────────────────────────────
          const Text(
            'Set Time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // ── Presets ──────────────────────────────────────────────────────
          const Text(
            'Quick Presets',
            style: TextStyle(
              color: _subtle,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final preset in _presets)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _hour = preset.hour;
                          _minute = preset.minute;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _hour == preset.hour && _minute == preset.minute
                              ? _accent.withAlpha(200)
                              : _surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _hour == preset.hour && _minute == preset.minute
                                ? _accent
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          preset.label,
                          style: TextStyle(
                            color: _hour == preset.hour && _minute == preset.minute
                                ? Colors.white
                                : _subtle,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Custom Time Picker ───────────────────────────────────────────
          const Text(
            'Custom Time',
            style: TextStyle(
              color: _subtle,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Hour spinner
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _hour = (_hour + 1) % 24;
                        });
                      },
                      child: const Icon(Icons.expand_less, color: _accent, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _dimmer),
                      ),
                      child: Text(
                        _hour.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _hour = (_hour - 1 + 24) % 24;
                        });
                      },
                      child: const Icon(Icons.expand_more, color: _accent, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Center(
                child: Text(
                  ':',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Minute spinner
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _minute = (_minute + 5) % 60;
                        });
                      },
                      child: const Icon(Icons.expand_less, color: _accent, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _dimmer),
                      ),
                      child: Text(
                        _minute.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _minute = (_minute - 5 + 60) % 60;
                        });
                      },
                      child: const Icon(Icons.expand_more, color: _accent, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Current time display ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, color: _accent, size: 16),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_hour, _minute),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Buttons ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _dimmer),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: _subtle,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onPicked(_hour, _minute);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
