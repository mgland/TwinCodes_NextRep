enum WarmupCooldownType {
  warmup,
  cooldown,
  both;

  String get displayName {
    switch (this) {
      case WarmupCooldownType.warmup:
        return 'Warm-Up';
      case WarmupCooldownType.cooldown:
        return 'Cool-Down';
      case WarmupCooldownType.both:
        return 'Both';
    }
  }
}

enum WarmupCooldownCategory {
  dynamicStretching,
  staticStretching,
  foamRolling,
  mobilityDrills,
  cardioWarmup,
  activationDrills,
  breathing,
  balance;

  String get displayName {
    switch (this) {
      case WarmupCooldownCategory.dynamicStretching:
        return 'Dynamic Stretching';
      case WarmupCooldownCategory.staticStretching:
        return 'Static Stretching';
      case WarmupCooldownCategory.foamRolling:
        return 'Foam Rolling';
      case WarmupCooldownCategory.mobilityDrills:
        return 'Mobility Drills';
      case WarmupCooldownCategory.cardioWarmup:
        return 'Cardio Warm-Up';
      case WarmupCooldownCategory.activationDrills:
        return 'Activation Drills';
      case WarmupCooldownCategory.breathing:
        return 'Breathing';
      case WarmupCooldownCategory.balance:
        return 'Balance';
    }
  }
}

class WarmupCooldownItem {
  final String id;
  final String name;
  final WarmupCooldownType type;
  final WarmupCooldownCategory category;
  bool isFavorite;

  WarmupCooldownItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    this.isFavorite = false,
  });
}
