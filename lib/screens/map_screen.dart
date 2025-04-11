import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:zappis/widgets/bottom_sheets/station_detail_bottom_sheet.dart';
import 'package:zappis/widgets/station_marker.dart';
import 'package:zappis/widgets/filter_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/station_provider.dart';
import 'package:zappis/screens/alerts_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  // Addis Ababa coordinates
  final LatLng _addisAbaba = const LatLng(9.0222, 38.7468);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stationProvider =
          Provider.of<StationProvider>(context, listen: false);
      stationProvider.fetchStations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<StationProvider>(
            builder: (context, stationProvider, _) {
              final stations = stationProvider.stations;

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _addisAbaba,
                  zoom: 13.0,
                  maxZoom: 18.0,
                  minZoom: 6.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: stations.map((station) {
                      return Marker(
                        point: LatLng(station.latitude, station.longitude),
                        child: StationMarker(
                          station: station,
                          onTap: () {
                            StationDetailBottomSheet.show(context, station.id);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for charging stations...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSearchFocused && _searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: _showFilterBottomSheet,
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onTap: () {
                  setState(() {
                    _isSearchFocused = true;
                  });
                },
                onSubmitted: (_) {
                  setState(() {
                    _isSearchFocused = false;
                  });
                },
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'locate',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    // Get user location and center map
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom + 1,
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
