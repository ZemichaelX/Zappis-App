import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger.dart';

class Booking {
  final String id;
  final Station station;
  final Charger charger;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final double chargingCost;
  final String status; // 'upcoming', 'completed', 'cancelled'
  final String? qrCode;

  Booking({
    required this.id,
    required this.station,
    required this.charger,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.chargingCost,
    required this.status,
    this.qrCode,
  });

  // Sample data for testing
  static List<Booking> getSampleBookings() {
    final stations = Station.getSampleStations();

    return [
      Booking(
        id: 'HEV12345',
        station: stations[0],
        charger: stations[0].chargers[0],
        date: DateTime.now().add(const Duration(days: 1)),
        startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        endTime:
            DateTime.now().add(const Duration(days: 1, hours: 11, minutes: 30)),
        chargingCost: 127.5,
        status: 'upcoming',
        qrCode: 'habesha-ev-booking:HEV12345',
      ),
      Booking(
        id: 'HEV12346',
        station: stations[1],
        charger: stations[1].chargers[0],
        date: DateTime.now().add(const Duration(days: 3)),
        startTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
        endTime:
            DateTime.now().add(const Duration(days: 3, hours: 15, minutes: 45)),
        chargingCost: 157.5,
        status: 'upcoming',
        qrCode: 'habesha-ev-booking:HEV12346',
      ),
      Booking(
        id: 'HEV12340',
        station: stations[0],
        charger: stations[0].chargers[1],
        date: DateTime.now().subtract(const Duration(days: 2)),
        startTime: DateTime.now().subtract(const Duration(days: 2, hours: 9)),
        endTime: DateTime.now()
            .subtract(const Duration(days: 2, hours: 7, minutes: 15)),
        chargingCost: 102.0,
        status: 'completed',
      ),
      Booking(
        id: 'HEV12341',
        station: stations[3],
        charger: stations[3].chargers[0],
        date: DateTime.now().subtract(const Duration(days: 5)),
        startTime: DateTime.now().subtract(const Duration(days: 5, hours: 16)),
        endTime: DateTime.now()
            .subtract(const Duration(days: 5, hours: 14, minutes: 30)),
        chargingCost: 212.5,
        status: 'completed',
      ),
    ];
  }
}
