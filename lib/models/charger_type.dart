class ChargerType {
  final String id;
  final String name;

  const ChargerType({
    required this.id,
    required this.name,
  });

  static const ChargerType ccs = ChargerType(id: 'ccs', name: 'CCS');
  static const ChargerType chademo =
      ChargerType(id: 'chademo', name: 'CHAdeMO');
  static const ChargerType type2 = ChargerType(id: 'type2', name: 'Type 2');

  static List<ChargerType> get all => [ccs, chademo, type2];
}
