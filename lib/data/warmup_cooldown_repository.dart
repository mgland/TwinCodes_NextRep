import '../models/warmup_cooldown.dart';

class WarmupCooldownRepository {
  static final WarmupCooldownRepository instance = WarmupCooldownRepository._();

  WarmupCooldownRepository._();

  final List<WarmupCooldownItem> items = [
    // ── Dynamic Stretching (Warmup) ────────────────────────────────────────
    WarmupCooldownItem(
      id: 'ds1',
      name: 'Arm Circles',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.dynamicStretching,
    ),
    WarmupCooldownItem(
      id: 'ds2',
      name: 'Hip Circles',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.dynamicStretching,
    ),
    WarmupCooldownItem(
      id: 'ds3',
      name: 'Leg Swings (Front-Back)',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.dynamicStretching,
    ),
    WarmupCooldownItem(
      id: 'ds4',
      name: 'Leg Swings (Side-to-Side)',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.dynamicStretching,
    ),
    WarmupCooldownItem(
      id: 'ds5',
      name: 'Neck Rolls',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.dynamicStretching,
    ),
    WarmupCooldownItem(
      id: 'ds6',
      name: 'Shoulder Rotations',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.dynamicStretching,
    ),
    WarmupCooldownItem(
      id: 'ds7',
      name: 'Trunk Rotations',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.dynamicStretching,
    ),
    WarmupCooldownItem(
      id: 'ds8',
      name: 'Wrist Circles',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.dynamicStretching,
    ),
    // ── Cardio Warm-Up ─────────────────────────────────────────────────────
    WarmupCooldownItem(
      id: 'cw1',
      name: 'Butt Kicks',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.cardioWarmup,
    ),
    WarmupCooldownItem(
      id: 'cw2',
      name: 'High Knees',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.cardioWarmup,
    ),
    WarmupCooldownItem(
      id: 'cw3',
      name: 'Inchworm',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.cardioWarmup,
    ),
    WarmupCooldownItem(
      id: 'cw4',
      name: 'Jump Rope',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.cardioWarmup,
    ),
    WarmupCooldownItem(
      id: 'cw5',
      name: 'Jumping Jacks',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.cardioWarmup,
    ),
    WarmupCooldownItem(
      id: 'cw6',
      name: 'Light Jog',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.cardioWarmup,
    ),
    WarmupCooldownItem(
      id: 'cw7',
      name: 'Skipping',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.cardioWarmup,
    ),
    // ── Activation Drills (Warmup) ─────────────────────────────────────────
    WarmupCooldownItem(
      id: 'ad1',
      name: 'Band Pull-Aparts',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.activationDrills,
    ),
    WarmupCooldownItem(
      id: 'ad2',
      name: 'Clamshells',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.activationDrills,
    ),
    WarmupCooldownItem(
      id: 'ad3',
      name: 'Dead Bug',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.activationDrills,
    ),
    WarmupCooldownItem(
      id: 'ad4',
      name: 'Glute Bridge Hold',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.activationDrills,
    ),
    WarmupCooldownItem(
      id: 'ad5',
      name: 'Monster Walks',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.activationDrills,
    ),
    WarmupCooldownItem(
      id: 'ad6',
      name: 'Wall Slides',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.activationDrills,
    ),
    // ── Static Stretching (Cooldown) ───────────────────────────────────────
    WarmupCooldownItem(
      id: 'ss1',
      name: 'Butterfly Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss2',
      name: 'Calf Stretch (Standing)',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss3',
      name: 'Chest Opener Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss4',
      name: 'Figure Four Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss5',
      name: 'Hamstring Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss6',
      name: 'Hip Flexor Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss7',
      name: 'Neck Side Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss8',
      name: 'Quad Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss9',
      name: 'Seated Forward Fold',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    WarmupCooldownItem(
      id: 'ss10',
      name: 'Tricep Overhead Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.staticStretching,
    ),
    // ── Mobility Drills (Both) ─────────────────────────────────────────────
    WarmupCooldownItem(
      id: 'mb1',
      name: 'Ankle Circles',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    WarmupCooldownItem(
      id: 'mb2',
      name: 'Cat-Cow',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    WarmupCooldownItem(
      id: 'mb3',
      name: 'Child\'s Pose',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    WarmupCooldownItem(
      id: 'mb4',
      name: 'Cobra Stretch',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    WarmupCooldownItem(
      id: 'mb5',
      name: 'Downward Dog',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    WarmupCooldownItem(
      id: 'mb6',
      name: 'Hip 90/90',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    WarmupCooldownItem(
      id: 'mb7',
      name: 'Pigeon Pose',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    WarmupCooldownItem(
      id: 'mb8',
      name: 'Supine Twist',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    WarmupCooldownItem(
      id: 'mb9',
      name: 'World\'s Greatest Stretch',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.mobilityDrills,
    ),
    // ── Foam Rolling (Both) ────────────────────────────────────────────────
    WarmupCooldownItem(
      id: 'fr1',
      name: 'Foam Roll Calves',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.foamRolling,
    ),
    WarmupCooldownItem(
      id: 'fr2',
      name: 'Foam Roll Glutes',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.foamRolling,
    ),
    WarmupCooldownItem(
      id: 'fr3',
      name: 'Foam Roll IT Band',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.foamRolling,
    ),
    WarmupCooldownItem(
      id: 'fr4',
      name: 'Foam Roll Lats',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.foamRolling,
    ),
    WarmupCooldownItem(
      id: 'fr5',
      name: 'Foam Roll Quads',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.foamRolling,
    ),
    WarmupCooldownItem(
      id: 'fr6',
      name: 'Foam Roll Thoracic Spine',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.foamRolling,
    ),
    WarmupCooldownItem(
      id: 'fr7',
      name: 'Foam Roll Upper Back',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.foamRolling,
    ),
    // ── Breathing (Both) ───────────────────────────────────────────────────
    WarmupCooldownItem(
      id: 'br1',
      name: 'Box Breathing',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.breathing,
    ),
    WarmupCooldownItem(
      id: 'br2',
      name: 'Deep Diaphragmatic Breathing',
      type: WarmupCooldownType.both,
      category: WarmupCooldownCategory.breathing,
    ),
    WarmupCooldownItem(
      id: 'br3',
      name: 'Pursed Lip Breathing',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.breathing,
    ),
    // ── Balance (Both) ─────────────────────────────────────────────────────
    WarmupCooldownItem(
      id: 'ba1',
      name: 'Single-Leg Balance Hold',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.balance,
    ),
    WarmupCooldownItem(
      id: 'ba2',
      name: 'Single-Leg Deadlift (Bodyweight)',
      type: WarmupCooldownType.warmup,
      category: WarmupCooldownCategory.balance,
    ),
    WarmupCooldownItem(
      id: 'ba3',
      name: 'Standing Figure Four Balance',
      type: WarmupCooldownType.cooldown,
      category: WarmupCooldownCategory.balance,
    ),
  ];
}
