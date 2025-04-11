import 'package:flutter/material.dart';
import 'package:zappis/models/booking.dart';

class ChargingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];

  List<Booking> get bookings => _bookings;

  List<Booking> get upcomingBookings =>
      _bookings.where((booking) => booking.status == 'upcoming').toList();

  List<Booking> get pastBookings => _bookings
      .where((booking) =>
          booking.status == 'completed' || booking.status == 'cancelled')
      .toList();

  Future<void> fetchBookings() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, we'll use sample data
    _bookings = Booking.getSampleBookings();
    notifyListeners();
  }

  Future<Booking> getBookingById(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Find booking in local cache
    final booking = _bookings.firstWhere(
      (booking) => booking.id == id,
      orElse: () => throw Exception('Booking not found'),
    );

    return booking;
  }

  Future<void> createBooking({
    required String stationId,
    required String chargerId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required double chargingCost,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, we would create a booking on the server
    // and then fetch the updated bookings list
    await fetchBookings();
  }

  Future<void> cancelBooking(String bookingId) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, we would cancel the booking on the server
    // and then fetch the updated bookings list
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);

    if (index != -1) {
      // For demo purposes, we'll just update the local state
      _bookings[index] = Booking(
        id: _bookings[index].id,
        station: _bookings[index].station,
        charger: _bookings[index].charger,
        date: _bookings[index].date,
        startTime: _bookings[index].startTime,
        endTime: _bookings[index].endTime,
        chargingCost: _bookings[index].chargingCost,
        status: 'cancelled',
        qrCode: _bookings[index].qrCode,
      );

      notifyListeners();
    }
  }
}
