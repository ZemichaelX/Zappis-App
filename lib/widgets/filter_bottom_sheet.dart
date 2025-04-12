import 'package:flutter/material.dart';
import 'package:zappis/models/charger_type.dart';
import 'package:zappis/widgets/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<ChargerType> initialChargerTypes;
  final double initialMaxDistance;
  final double initialMaxPrice;
  final bool initialOnlyAvailable;
  final List<String> initialSelectedServices;
  final Function(Map<String, dynamic>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialChargerTypes,
    required this.initialMaxDistance,
    required this.initialMaxPrice,
    required this.initialOnlyAvailable,
    required this.initialSelectedServices,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<ChargerType> _selectedChargerTypes;
  late double _maxDistance;
  late double _maxPrice;
  late bool _onlyAvailable;
  late List<String> _selectedServices;

  final List<Map<String, dynamic>> _availableServices = [
    {'name': 'Coffee', 'icon': Icons.coffee},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Store', 'icon': Icons.shopping_basket},
    {'name': 'Wi-Fi', 'icon': Icons.wifi},
    {'name': 'Restroom', 'icon': Icons.wc},
    {'name': 'Parking', 'icon': Icons.local_parking},
    {'name': 'Car Wash', 'icon': Icons.water_drop},
  ];

  @override
  void initState() {
    super.initState();
    _selectedChargerTypes = widget.initialChargerTypes;
    _maxDistance = widget.initialMaxDistance;
    _maxPrice = widget.initialMaxPrice;
    _onlyAvailable = widget.initialOnlyAvailable;
    _selectedServices = widget.initialSelectedServices;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
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
                  String prefix;
                  String power;
                  switch (type.name) {
                    case 'CCS':
                      prefix = 'Fast';
                      power = '50 kW';
                      break;
                    case 'CHAdeMO':
                      prefix = 'Fast';
                      power = '50 kW';
                      break;
                    case 'Type 2':
                      prefix = 'Standard';
                      power = '22 kW';
                      break;
                    default:
                      prefix = '';
                      power = '';
                  }
                  return CheckboxListTile(
                    title: Text('$prefix - ${type.name} ($power)'),
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
              const Text(
                'Nearby Services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _availableServices.length,
                itemBuilder: (context, index) {
                  final service = _availableServices[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (_selectedServices.contains(service['name'])) {
                          _selectedServices.remove(service['name']);
                        } else {
                          _selectedServices.add(service['name']);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedServices.contains(service['name'])
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedServices.contains(service['name'])
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            service['icon'],
                            color: _selectedServices.contains(service['name'])
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedServices.contains(service['name'])
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                          _selectedServices.clear();
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
                        widget.onApply({
                          'chargerTypes': _selectedChargerTypes,
                          'maxDistance': _maxDistance,
                          'maxPrice': _maxPrice,
                          'onlyAvailable': _onlyAvailable,
                          'selectedServices': _selectedServices,
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
