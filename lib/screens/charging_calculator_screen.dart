import 'package:flutter/material.dart';
import 'package:zappis/models/charger_type.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/widgets/custom_button.dart';

class CarModel {
  final String brand;
  final String model;
  final double batteryCapacity;
  final bool isOther;

  const CarModel({
    required this.brand,
    required this.model,
    required this.batteryCapacity,
    this.isOther = false,
  });
}

class ChargingCalculatorScreen extends StatefulWidget {
  final Station? station;

  const ChargingCalculatorScreen({
    super.key,
    this.station,
  });

  @override
  State<ChargingCalculatorScreen> createState() =>
      _ChargingCalculatorScreenState();
}

class _ChargingCalculatorScreenState extends State<ChargingCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ChargerType? _selectedChargerType;
  CarModel? _selectedCar;
  double _currentBatteryPercentage = 20;
  double _targetBatteryPercentage = 80;
  double _batteryCapacity = 60; // kWh
  double _pricePerKwh = 8.0; // Default price in Birr
  final TextEditingController _otherBrandController = TextEditingController();
  final TextEditingController _otherModelController = TextEditingController();

  double _chargingTime = 0;
  double _chargingCost = 0;

  final List<CarModel> _commonCars = [
    CarModel(
        brand: 'Tesla', model: 'Model 3 Standard Range', batteryCapacity: 60),
    CarModel(brand: 'Tesla', model: 'Model 3 Long Range', batteryCapacity: 82),
    CarModel(brand: 'Tesla', model: 'Model Y', batteryCapacity: 75),
    CarModel(brand: 'Volkswagen', model: 'ID.4', batteryCapacity: 77),
    CarModel(brand: 'Hyundai', model: 'IONIQ 5', batteryCapacity: 72.6),
    CarModel(brand: 'Kia', model: 'EV6', batteryCapacity: 77.4),
    CarModel(brand: 'BMW', model: 'i4', batteryCapacity: 83.9),
    CarModel(brand: 'Mercedes', model: 'EQS', batteryCapacity: 107.8),
    CarModel(brand: 'Porsche', model: 'Taycan', batteryCapacity: 93.4),
    CarModel(brand: 'Audi', model: 'e-tron GT', batteryCapacity: 93.4),
    CarModel(brand: 'Ford', model: 'Mustang Mach-E', batteryCapacity: 75.7),
    CarModel(brand: 'Nissan', model: 'Leaf e+', batteryCapacity: 62),
    CarModel(brand: 'Chevrolet', model: 'Bolt EV', batteryCapacity: 65),
    CarModel(
        brand: 'Others', model: 'Custom', batteryCapacity: 60, isOther: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedChargerType = ChargerType.all.firstWhere((t) => t.name == 'CCS');
    _selectedCar = _commonCars[0];
    _tabController.addListener(_handleTabChange);
    if (widget.station != null) {
      _pricePerKwh = widget.station!.price;
    }
    _calculateChargingDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _otherBrandController.dispose();
    _otherModelController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_selectedChargerType != null) {
      setState(() {
        // Update charger type based on tab
        if (_tabController.index == 0) {
          // Fast charging tab
          _selectedChargerType =
              ChargerType.all.firstWhere((t) => t.name == 'CCS');
        } else {
          // Standard charging tab
          _selectedChargerType =
              ChargerType.all.firstWhere((t) => t.name == 'Type 2');
        }
      });
      _calculateChargingDetails();
    }
  }

  void _calculateChargingDetails() {
    if (_selectedChargerType == null) return;

    // Calculate energy needed in kWh
    final energyNeeded = _batteryCapacity *
        (_targetBatteryPercentage - _currentBatteryPercentage) /
        100;

    // Get charger power based on type
    final chargerPower = _selectedChargerType!.name == 'CCS'
        ? 50.0
        : _selectedChargerType!.name == 'CHAdeMO'
            ? 50.0
            : 22.0; // Type 2

    // Calculate charging time in hours
    _chargingTime = energyNeeded / chargerPower;

    // Calculate cost in Birr
    _chargingCost = energyNeeded * _pricePerKwh;

    setState(() {});
  }

  String _formatDuration(double hours) {
    final totalMinutes = (hours * 60).round();
    final hrs = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;

    if (hrs > 0) {
      return '$hrs hr ${mins > 0 ? '$mins min' : ''}';
    } else {
      return '$mins min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Calculator'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Fixed Tab Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _tabController.index == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _tabController.index == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        child: const Text(
                          'Fast Charging',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _tabController.index == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        child: const Text(
                          'Standard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalculatorContent(isFastCharging: true),
                _buildCalculatorContent(isFastCharging: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorContent({required bool isFastCharging}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Charger Type Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              isFastCharging
                  ? '50 kW DC Fast Charging (CCS/CHAdeMO) - 9.5 Birr/kWh'
                  : '22 kW AC Standard Charging (Type 2) - 8.0 Birr/kWh',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Rest of the content
          if (widget.station != null) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.station!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.station!.address,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.station!.price} Birr/kWh',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your Car',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<CarModel>(
                    value: _selectedCar,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _commonCars.map((car) {
                      return DropdownMenuItem<CarModel>(
                        value: car,
                        child: Text(
                          car.isOther
                              ? 'Others (Custom Car)'
                              : '${car.brand} ${car.model} (${car.batteryCapacity} kWh)',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCar = value;
                          _batteryCapacity = value.batteryCapacity;
                          if (value.isOther) {
                            _otherBrandController.clear();
                            _otherModelController.clear();
                          }
                        });
                        _calculateChargingDetails();
                      }
                    },
                  ),
                  if (_selectedCar != null && _selectedCar!.isOther) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _otherBrandController,
                      decoration: const InputDecoration(
                        labelText: 'Car Brand',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _otherModelController,
                      decoration: const InputDecoration(
                        labelText: 'Car Model',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Battery Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Battery Capacity (kWh)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _batteryCapacity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixText: 'kWh',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _batteryCapacity =
                            double.tryParse(value) ?? _batteryCapacity;
                      });
                      _calculateChargingDetails();
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Current Battery Level'),
                  Slider(
                    value: _currentBatteryPercentage,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${_currentBatteryPercentage.round()}%',
                    onChanged: (value) {
                      setState(() {
                        _currentBatteryPercentage = value;
                      });
                      _calculateChargingDetails();
                    },
                  ),
                  const Text('Target Battery Level'),
                  Slider(
                    value: _targetBatteryPercentage,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${_targetBatteryPercentage.round()}%',
                    onChanged: (value) {
                      setState(() {
                        _targetBatteryPercentage = value;
                      });
                      _calculateChargingDetails();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Charging Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.timer, size: 32),
                          const SizedBox(height: 8),
                          const Text(
                            'Charging Time',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(_chargingTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.attach_money, size: 32),
                          const SizedBox(height: 8),
                          const Text(
                            'Estimated Cost',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_chargingCost.toStringAsFixed(2)} Birr',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
