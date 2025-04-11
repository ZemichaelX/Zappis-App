import 'package:flutter/material.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger_type.dart';
import 'package:zappis/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/station_provider.dart';

class CreateAlertScreen extends StatefulWidget {
  final Station? station;

  const CreateAlertScreen({
    super.key,
    this.station,
  });

  @override
  State<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends State<CreateAlertScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Alert'),
      ),
      body: SingleChildScrollView(
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
    );
  }
}
