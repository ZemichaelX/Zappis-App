import 'package:flutter/material.dart';
import 'package:zappis/models/booking.dart';
import 'package:zappis/screens/booking_detail_screen.dart';
import 'package:zappis/widgets/booking_card.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/charging_provider.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chargingProvider =
          Provider.of<ChargingProvider>(context, listen: false);
      chargingProvider.fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<ChargingProvider>(
        builder: (context, chargingProvider, child) {
          final upcomingBookings = chargingProvider.upcomingBookings;
          final pastBookings = chargingProvider.pastBookings;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(upcomingBookings, 'No upcoming bookings'),
              _buildBookingsList(pastBookings, 'No past bookings'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BookingCard(
            booking: booking,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingDetailScreen(
                    bookingId: booking.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
