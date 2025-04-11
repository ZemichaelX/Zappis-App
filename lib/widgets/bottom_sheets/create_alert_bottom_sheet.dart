import 'package:flutter/material.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger_type.dart';
import 'package:zappis/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/station_provider.dart';

class CreateAlertBottomSheet extends StatefulWidget {
  final Station? station;

  const CreateAlertBottomSheet({
    super.key,
    this.station,
  });

  static Future<void> show(BuildContext context, [Station? station]) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlertBottomSheet(station: station),
    );
  }

  @override
  State<CreateAlertBottomSheet> createState() => _CreateAlertBottomSheetState();
}

class _CreateAlertBottomSheetState extends State<CreateAlertBottomSheet> {
  Station? _selectedStation;
  List<Station> _stations = [];
  final List<ChargerType> _selectedChargerTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStation = widget.station;
    _loadStations();
  }

  Future<void> _loadStations() async {
    final stationProvider =
        Provider.of<StationProvider>(context, listen: false);
    await stationProvider.fetchStations();

    if (mounted) {
      setState(() {
        _stations = stationProvider.stations;
        if (_selectedStation == null && _stations.isNotEmpty) {
          _selectedStation = _stations.first;
        }
      });
    }
  }

  Future<void> _createAlert() async {
    if (_selectedStation == null || _selectedChargerTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select a station and at least one charger type')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final stationProvider =
          Provider.of<StationProvider>(context, listen: false);
      await stationProvider.createAlert(
        stationId: _selectedStation!.id,
        stationName: _selectedStation!.name,
        type: 'availability',
        message: 'New charger available',
        chargerTypes: _selectedChargerTypes.map((type) => type.id).toList(),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert created successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create alert: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get notified when your preferred chargers become available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Station',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Station>(
                    value: _selectedStation,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _stations.map((station) {
                      return DropdownMenuItem<Station>(
                        value: station,
                        child: Text(station.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStation = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Charger Types',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: ChargerType.all.map((type) {
                        return CheckboxListTile(
                          title: Text(type.name),
                          value: _selectedChargerTypes.contains(type),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedChargerTypes.add(type);
                              } else {
                                _selectedChargerTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Create Alert',
                    isLoading: _isLoading,
                    onPressed: _createAlert,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Create Alert',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
