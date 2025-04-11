
class Alert {
  final String id;
  final String stationId;
  final String stationName;
  final String type;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final List<String> chargerTypes;

  const Alert({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.chargerTypes,
  });

  Alert copyWith({
    String? id,
    String? stationId,
    String? stationName,
    String? type,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    List<String>? chargerTypes,
  }) {
    return Alert(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      type: type ?? this.type,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      chargerTypes: chargerTypes ?? this.chargerTypes,
    );
  }
}

// Sample data for testing
final sampleAlerts = [
  Alert(
    id: '1',
    stationId: '1',
    stationName: 'Meskel Square Charging Hub',
    type: 'availability',
    message: 'CCS charger is now available',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
    chargerTypes: ['CCS', 'CHAdeMO'],
  ),
  Alert(
    id: '2',
    stationId: '2',
    stationName: 'Bole Charging Station',
    type: 'price',
    message: 'Price has decreased to 7.5 Birr/kWh',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
    chargerTypes: ['Type 2', 'CCS'],
  ),
  Alert(
    id: '3',
    stationId: '3',
    stationName: 'Addis Ababa Science Museum',
    type: 'availability',
    message: 'New CHAdeMO charger installed',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isRead: false,
    chargerTypes: ['CHAdeMO'],
  ),
];
