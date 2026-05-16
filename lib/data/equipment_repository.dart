import '../models/equipment.dart';

class EquipmentRepository {
  static final EquipmentRepository instance = EquipmentRepository._();

  EquipmentRepository._();

  final List<Equipment> equipment = [
    // Free Weights
    Equipment(id: 'fw1', name: 'Barbell', category: EquipmentCategory.freeWeights),
    Equipment(id: 'fw2', name: 'Dumbbells', category: EquipmentCategory.freeWeights),
    Equipment(id: 'fw3', name: 'Kettlebell', category: EquipmentCategory.freeWeights),
    Equipment(id: 'fw4', name: 'Weight Plate', category: EquipmentCategory.freeWeights),

    // Machines
    Equipment(id: 'm1', name: 'Chest Press Machine', category: EquipmentCategory.machines),
    Equipment(id: 'm2', name: 'Leg Press Machine', category: EquipmentCategory.machines),
    Equipment(id: 'm3', name: 'Lat Pulldown Machine', category: EquipmentCategory.machines),
    Equipment(id: 'm4', name: 'Seated Row Machine', category: EquipmentCategory.machines),
    Equipment(id: 'm5', name: 'Smith Machine', category: EquipmentCategory.machines),

    // Cables
    Equipment(id: 'c1', name: 'Cable Tower', category: EquipmentCategory.cables),
    Equipment(id: 'c2', name: 'Rope Attachment', category: EquipmentCategory.cables),
    Equipment(id: 'c3', name: 'D-Handle Attachment', category: EquipmentCategory.cables),
    Equipment(id: 'c4', name: 'Straight Bar Attachment', category: EquipmentCategory.cables),

    // Bodyweight
    Equipment(id: 'bw1', name: 'Pull Up Bar', category: EquipmentCategory.bodyweight),
    Equipment(id: 'bw2', name: 'Dip Station', category: EquipmentCategory.bodyweight),
    Equipment(id: 'bw3', name: 'Push Up Handles', category: EquipmentCategory.bodyweight),

    // Cardio
    Equipment(id: 'ca1', name: 'Air Bike', category: EquipmentCategory.cardio),
    Equipment(id: 'ca2', name: 'Elliptical Trainer', category: EquipmentCategory.cardio),
    Equipment(id: 'ca3', name: 'Rower', category: EquipmentCategory.cardio),
    Equipment(id: 'ca4', name: 'Spin Bike', category: EquipmentCategory.cardio),
    Equipment(id: 'ca5', name: 'Treadmill', category: EquipmentCategory.cardio),

    // Mobility
    Equipment(id: 'mo1', name: 'Foam Roller', category: EquipmentCategory.mobility),
    Equipment(id: 'mo2', name: 'Lacrosse Ball', category: EquipmentCategory.mobility),
    Equipment(id: 'mo3', name: 'Massage Gun', category: EquipmentCategory.mobility),
    Equipment(id: 'mo4', name: 'Resistance Band', category: EquipmentCategory.mobility),

    // Accessories
    Equipment(id: 'a1', name: 'Ankle Strap', category: EquipmentCategory.accessories),
    Equipment(id: 'a2', name: 'Gymnastic Rings', category: EquipmentCategory.accessories),
    Equipment(id: 'a3', name: 'Lifting Belt', category: EquipmentCategory.accessories),
    Equipment(id: 'a4', name: 'Lifting Straps', category: EquipmentCategory.accessories),
    Equipment(id: 'a5', name: 'Wrist Wraps', category: EquipmentCategory.accessories),

    // Bars
    Equipment(id: 'b1', name: 'EZ Curl Bar', category: EquipmentCategory.bars),
    Equipment(id: 'b2', name: 'Hex Trap Bar', category: EquipmentCategory.bars),
    Equipment(id: 'b3', name: 'Olympic Barbell', category: EquipmentCategory.bars),
    Equipment(id: 'b4', name: 'Safety Squat Bar', category: EquipmentCategory.bars),

    // Benches
    Equipment(id: 'be1', name: 'Adjustable Bench', category: EquipmentCategory.benches),
    Equipment(id: 'be2', name: 'Flat Bench', category: EquipmentCategory.benches),
    Equipment(id: 'be3', name: 'Incline Bench', category: EquipmentCategory.benches),

    // Racks
    Equipment(id: 'r1', name: 'Half Rack', category: EquipmentCategory.racks),
    Equipment(id: 'r2', name: 'Power Rack', category: EquipmentCategory.racks),
    Equipment(id: 'r3', name: 'Squat Stand', category: EquipmentCategory.racks),
  ];
}
