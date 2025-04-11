class Charger {
  final String id;
  final String type; // CCS, CHAdeMO, Type 2, etc.
  final double power; // kW
  final bool isAvailable;

  Charger({
    required this.id,
    required this.type,
    required this.power,
    required this.isAvailable,
  });

  // Create a copy of the charger with updated properties
  Charger copyWith({
    String? id,
    String? type,
    double? power,
    bool? isAvailable,
  }) {
    return Charger(
      id: id ?? this.id,
      type: type ?? this.type,
      power: power ?? this.power,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
