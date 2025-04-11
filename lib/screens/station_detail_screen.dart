import 'package:flutter/material.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/screens/charging_calculator_screen.dart';
import 'package:zappis/screens/booking_screen.dart';
import 'package:zappis/widgets/charger_card.dart';
import 'package:zappis/widgets/service_card.dart';
import 'package:zappis/widgets/bottom_sheets/create_alert_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/station_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StationDetailScreen extends StatefulWidget {
  final String stationId;

  const StationDetailScreen({
    super.key,
    required this.stationId,
  });

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Station? _station;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStationDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStationDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stationProvider =
          Provider.of<StationProvider>(context, listen: false);
      final station = await stationProvider.getStationById(widget.stationId);

      if (mounted) {
        setState(() {
          _station = station;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load station details: ${e.toString()}')),
        );
      }
    }
  }

  void _openDirections() async {
    if (_station == null) return;

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${_station!.latitude},${_station!.longitude}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open directions')),
        );
      }
    }
  }

  void _toggleFavorite() {
    if (_station == null) return;

    final stationProvider =
        Provider.of<StationProvider>(context, listen: false);
    stationProvider.toggleFavorite(_station!.id);
  }

  void _setAlert() {
    if (_station == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CreateAlertBottomSheet(station: _station!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _station == null
              ? const Center(child: Text('Station not found'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(_station!.name),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/station_header.jpg',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            _station!.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _station!.isFavorite
                                ? Colors.red
                                : Colors.white,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none),
                          onPressed: _setAlert,
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _station!.address,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.directions),
                                  label: const Text('Directions'),
                                  onPressed: _openDirections,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bolt,
                                        size: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_station!.price} Birr/kWh',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _station!.availableSpots > 0
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.ev_station,
                                        size: 16,
                                        color: _station!.availableSpots > 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_station!.availableSpots}/${_station!.totalSpots} Available',
                                        style: TextStyle(
                                          color: _station!.availableSpots > 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.calculate),
                                    label: const Text('Calculate'),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ChargingCalculatorScreen(
                                            station: _station!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.book_online),
                                    label: const Text('Book Now'),
                                    onPressed: _station!.availableSpots > 0
                                        ? () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => BookingScreen(
                                                  station: _station!,
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                          tabs: const [
                            Tab(text: 'Chargers'),
                            Tab(text: 'Services'),
                            Tab(text: 'Info'),
                          ],
                        ),
                      ),
                      pinned: true,
                    ),
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildChargersTab(),
                          _buildServicesTab(),
                          _buildInfoTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildChargersTab() {
    if (_station == null) return const SizedBox();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _station!.chargers.length,
      itemBuilder: (context, index) {
        final charger = _station!.chargers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ChargerCard(
            charger: charger,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingScreen(
                    station: _station!,
                    selectedChargerId: charger.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    if (_station == null) return const SizedBox();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _station!.services.length,
      itemBuilder: (context, index) {
        final service = _station!.services[index];
        return ServiceCard(service: service);
      },
    );
  }

  Widget _buildInfoTab() {
    if (_station == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(_station!.description),
        const SizedBox(height: 16),
        const Text(
          'Opening Hours',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildOpeningHours(),
        const SizedBox(height: 16),
        const Text(
          'Contact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.phone),
          title: Text(_station!.phone),
          contentPadding: EdgeInsets.zero,
          onTap: () async {
            final url = 'tel:${_station!.phone}';
            if (await canLaunch(url)) {
              await launch(url);
            }
          },
        ),
        if (_station!.email != null)
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(_station!.email!),
            contentPadding: EdgeInsets.zero,
            onTap: () async {
              final url = 'mailto:${_station!.email}';
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
          ),
      ],
    );
  }

  Widget _buildOpeningHours() {
    if (_station == null) return const SizedBox();

    return Column(
      children: [
        _buildOpeningHourRow('Monday - Friday', '8:00 AM - 8:00 PM'),
        _buildOpeningHourRow('Saturday', '9:00 AM - 6:00 PM'),
        _buildOpeningHourRow('Sunday', '10:00 AM - 4:00 PM'),
      ],
    );
  }

  Widget _buildOpeningHourRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(hours),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
