import 'package:flutter/material.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger.dart';
import 'package:zappis/models/charger_type.dart';
import 'package:zappis/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:zappis/providers/station_provider.dart';

class CreateAlertBottomSheet extends StatefulWidget {
  final Station station;
  final Charger? charger;

  const CreateAlertBottomSheet({
    super.key,
    required this.station,
    this.charger,
  });

  static Future<void> show(BuildContext context, Station station,
      [Charger? charger]) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlertBottomSheet(
        station: station,
        charger: charger,
      ),
    );
  }

  @override
  State<CreateAlertBottomSheet> createState() => _CreateAlertBottomSheetState();
}

class _CreateAlertBottomSheetState extends State<CreateAlertBottomSheet> {
  final List<ChargerType> _selectedChargerTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.charger != null) {
      final chargerType = ChargerType.all.firstWhere(
        (type) => type.name == widget.charger!.type,
        orElse: () => ChargerType.all.first,
      );
      _selectedChargerTypes.add(chargerType);
    }
  }

  Future<void> _createAlert() async {
    if (_selectedChargerTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one charger type')),
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
        stationId: widget.station.id,
        stationName: widget.station.name,
        type: 'availability',
        message: 'New charger available',
        chargerTypes: _selectedChargerTypes.map((type) => type.id).toList(),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      final chargerTypes = _selectedChargerTypes.map((t) => t.name).join(', ');

      // Show success dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Alert Set Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.charger != null
                    ? 'We will notify you when this ${widget.charger!.type} charger becomes available at ${widget.station.name}'
                    : 'We will notify you when any $chargerTypes charger becomes available at ${widget.station.name}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Show SnackBar as additional confirmation
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.charger != null
                ? 'Alert set for ${widget.charger!.type} charger'
                : 'Alert set for charger types: $chargerTypes',
          ),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
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
      height: screenHeight * 0.5,
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
                  Text(
                    'Get notified when chargers become available at ${widget.station.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.charger == null) ...[
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
                  ],
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
            'Create Availability Alert',
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
