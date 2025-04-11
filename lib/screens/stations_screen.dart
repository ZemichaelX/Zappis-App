import 'package:flutter/material.dart';
import 'package:zappis/widgets/bottom_sheets/station_detail_bottom_sheet.dart';
import 'package:zappis/widgets/station_list_item.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/station_provider.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<StationProvider>(
              builder: (context, stationProvider, child) {
                final stations = stationProvider.stations;

                if (stations.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final filteredStations = _searchQuery.isEmpty
                    ? stations
                    : stations.where((station) {
                        return station.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()) ||
                            station.address
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase());
                      }).toList();

                if (filteredStations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stations found',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredStations.length,
                  itemBuilder: (context, index) {
                    final station = filteredStations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: StationListItem(
                        station: station,
                        onTap: () {
                          StationDetailBottomSheet.show(context, station.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
