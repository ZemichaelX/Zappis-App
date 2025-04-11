import 'package:flutter/material.dart';
import 'package:zappis/models/charger_type.dart';
import 'package:zappis/widgets/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final List<ChargerType> _selectedChargerTypes = [];
  double _maxDistance = 10.0;
  double _maxPrice = 15.0;
  bool _onlyAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Stations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Charger Types',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
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
          const SizedBox(height: 16),
          const Text(
            'Maximum Distance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _maxDistance,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: '${_maxDistance.round()} km',
                  onChanged: (value) {
                    setState(() {
                      _maxDistance = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '${_maxDistance.round()} km',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Maximum Price',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _maxPrice,
                  min: 5.0,
                  max: 20.0,
                  divisions: 15,
                  label: '${_maxPrice.round()} Birr/kWh',
                  onChanged: (value) {
                    setState(() {
                      _maxPrice = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  '${_maxPrice.round()} Birr/kWh',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Show only available stations',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            value: _onlyAvailable,
            onChanged: (value) {
              setState(() {
                _onlyAvailable = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Reset filters
                    setState(() {
                      _selectedChargerTypes.clear();
                      _maxDistance = 10.0;
                      _maxPrice = 15.0;
                      _onlyAvailable = true;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Apply',
                  onPressed: () {
                    Navigator.of(context).pop({
                      'chargerTypes': _selectedChargerTypes,
                      'maxDistance': _maxDistance,
                      'maxPrice': _maxPrice,
                      'onlyAvailable': _onlyAvailable,
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
