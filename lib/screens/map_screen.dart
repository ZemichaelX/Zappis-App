import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:zappis/widgets/bottom_sheets/station_detail_bottom_sheet.dart';
import 'package:zappis/widgets/station_marker.dart';
import 'package:zappis/widgets/filter_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/station_provider.dart';
import 'package:zappis/screens/alerts_screen.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:typed_data';

class CachedTileProvider extends TileProvider {
  CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    final url = getTileUrl(coords, options);
    final file = DefaultCacheManager().getSingleFile(url);
    return NetworkImage(url);
  }

  String getTileUrl(TileCoordinates coords, TileLayer options) {
    final z = coords.z;
    final x = coords.x;
    final y = coords.y;
    return 'https://tile.openstreetmap.org/$z/$x/$y.png';
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;
  List<ChargerType> _selectedChargerTypes = [];
  double _maxDistance = 10.0;
  double _maxPrice = 15.0;
  bool _onlyAvailable = true;
  List<String> _selectedServices = [];
  bool _isMapReady = false;
  bool _isLoading = false;

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
      builder: (context) => FilterBottomSheet(
        initialChargerTypes: _selectedChargerTypes,
        initialMaxDistance: _maxDistance,
        initialMaxPrice: _maxPrice,
        initialOnlyAvailable: _onlyAvailable,
        initialSelectedServices: _selectedServices,
        onApply: (filters) {
          setState(() {
            _selectedChargerTypes =
                filters['chargerTypes'] as List<ChargerType>;
            _maxDistance = filters['maxDistance'] as double;
            _maxPrice = filters['maxPrice'] as double;
            _onlyAvailable = filters['onlyAvailable'] as bool;
            _selectedServices = filters['selectedServices'] as List<String>;
          });
        },
      ),
    );
  }

  bool _isStationVisible(Station station) {
    // Check if station is within max distance
    if (station.distance > _maxDistance) return false;

    // Check if station price is within max price
    if (station.price > _maxPrice) return false;

    // Check if station has available spots (if onlyAvailable is true)
    if (_onlyAvailable && station.availableSpots == 0) return false;

    // Check if station has any of the selected charger types
    if (_selectedChargerTypes.isNotEmpty) {
      final hasSelectedChargerType = station.chargers.any((charger) =>
          _selectedChargerTypes.any((type) => type.name == charger.type));
      if (!hasSelectedChargerType) return false;
    }

    // Check if station has any of the selected services
    if (_selectedServices.isNotEmpty) {
      final hasSelectedService = station.services
          .any((service) => _selectedServices.contains(service.name));
      if (!hasSelectedService) return false;
    }

    return true;
  }

  void _closeBottomSheet() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Marker> _buildMarkers() {
    return context.read<StationProvider>().stations.map((station) {
      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 40,
        height: 40,
        child: StationMarker(
          station: station,
          onTap: () => StationDetailBottomSheet.show(context, station.id),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _addisAbaba,
              zoom: 13.0,
              onTap: (_, __) => _closeBottomSheet(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                tileProvider: CachedTileProvider(),
                userAgentPackageName: 'com.zappis.app',
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: FloatingActionButton(
                        heroTag: 'locate',
                        onPressed: _getCurrentLocation,
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: FloatingActionButton(
                        heroTag: 'zoom_in',
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: FloatingActionButton(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for stations...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _isSearchFocused = true;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        _isSearchFocused = false;
                      });
                      // TODO: Implement search functionality
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFilterBottomSheet,
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
