enum EquipmentCategory {
  freeWeights,
  machines,
  cables,
  bodyweight,
  cardio,
  mobility,
  accessories,
  bars,
  benches,
  racks;

  String get displayName {
    switch (this) {
      case EquipmentCategory.freeWeights:
        return 'Free Weights';
      case EquipmentCategory.machines:
        return 'Machines';
      case EquipmentCategory.cables:
        return 'Cables';
      case EquipmentCategory.bodyweight:
        return 'Bodyweight';
      case EquipmentCategory.cardio:
        return 'Cardio';
      case EquipmentCategory.mobility:
        return 'Mobility';
      case EquipmentCategory.accessories:
        return 'Accessories';
      case EquipmentCategory.bars:
        return 'Bars';
      case EquipmentCategory.benches:
        return 'Benches';
      case EquipmentCategory.racks:
        return 'Racks';
    }
  }
}

class Equipment {
  final String id;
  final String name;
  final EquipmentCategory category;
  bool isFavorite;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    this.isFavorite = false,
  });
}
