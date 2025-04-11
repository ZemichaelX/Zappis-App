import 'package:flutter/material.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger.dart';
import 'package:zappis/widgets/bottom_sheets/booking_bottom_sheet.dart';
import 'package:zappis/widgets/custom_button.dart';

class ChargingCalculatorBottomSheet extends StatefulWidget {
  final Station station;
  
  const ChargingCalculatorBottomSheet({
    super.key,
    required this.station,
  });

  static Future<void> show(BuildContext context, Station station) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChargingCalculatorBottomSheet(station: station),
    );
  }

  @override
  State<ChargingCalculatorBottomSheet> createState() => _ChargingCalculatorBottomSheetState();
}

class _ChargingCalculatorBottomSheetState extends State<ChargingCalculatorBottomSheet> {
  Charger? _selectedCharger;
  double _currentBatteryPercentage = 20;
  double _targetBatteryPercentage = 80;
  double _batteryCapacity = 60; // kWh
  
  double _chargingTime = 0;
  double _chargingCost = 0;
  
  @override
  void initState() {
    super.initState();
    if (widget.station.chargers.isNotEmpty) {
      _selectedCharger = widget.station.chargers.first;
    }
    _calculateChargingDetails();
  }
  
  void _calculateChargingDetails() {
    if (_selectedCharger == null) return;
    
    // Calculate energy needed in kWh
    final energyNeeded = _batteryCapacity * (_targetBatteryPercentage - _currentBatteryPercentage) / 100;
    
    // Calculate charging time in hours
    _chargingTime = energyNeeded / _selectedCharger!.power;
    
    // Calculate cost in Birr
    _chargingCost = energyNeeded * widget.station.price;
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.9,
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.station.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.station.address,
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
                                '${widget.station.price} Birr/kWh',
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
                  const SizedBox(height: 24),
                  const Text(
                    'Charger Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Charger>(
                    value: _selectedCharger,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: widget.station.chargers.map((charger) {
                      return DropdownMenuItem<Charger>(
                        value: charger,
                        child: Text('${charger.type} - ${charger.power} kW'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCharger = value;
                      });
                      _calculateChargingDetails();
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Battery Capacity (kWh)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _batteryCapacity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixText: 'kWh',
                    ),
                    onChanged: (value) {
                      final capacity = double.tryParse(value);
                      if (capacity != null && capacity > 0) {
                        setState(() {
                          _batteryCapacity = capacity;
                        });
                        _calculateChargingDetails();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Current Battery Percentage',
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
                          value: _currentBatteryPercentage,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '${_currentBatteryPercentage.round()}%',
                          onChanged: (value) {
                            setState(() {
                              _currentBatteryPercentage = value;
                              if (_currentBatteryPercentage >= _targetBatteryPercentage) {
                                _targetBatteryPercentage = _currentBatteryPercentage + 5;
                                if (_targetBatteryPercentage > 100) {
                                  _targetBatteryPercentage = 100;
                                }
                              }
                            });
                            _calculateChargingDetails();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${_currentBatteryPercentage.round()}%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Target Battery Percentage',
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
                          value: _targetBatteryPercentage,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '${_targetBatteryPercentage.round()}%',
                          onChanged: (value) {
                            setState(() {
                              _targetBatteryPercentage = value;
                              if (_targetBatteryPercentage <= _currentBatteryPercentage) {
                                _currentBatteryPercentage = _targetBatteryPercentage - 5;
                                if (_currentBatteryPercentage < 0) {
                                  _currentBatteryPercentage = 0;
                                }
                              }
                            });
                            _calculateChargingDetails();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${_targetBatteryPercentage.round()}%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Card(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Charging Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            'Energy Required',
                            '${(_batteryCapacity * (_targetBatteryPercentage - _currentBatteryPercentage) / 100).toStringAsFixed(2)} kWh',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Charging Time',
                            _formatDuration(_chargingTime * 60),
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Estimated Cost',
                            '${_chargingCost.toStringAsFixed(2)} Birr',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Book This Charger',
                    onPressed: () {
                      if (_selectedCharger == null) return;
                      
                      Navigator.of(context).pop();
                      BookingBottomSheet.show(
                        context,
                        widget.station,
                        selectedChargerId: _selectedCharger!.id,
                        currentBatteryPercentage: _currentBatteryPercentage,
                        targetBatteryPercentage: _targetBatteryPercentage,
                      );
                    },
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
            Icons.calculate,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Charging Calculator',
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
  
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  String _formatDuration(double minutes) {
    final int hours = minutes ~/ 60;
    final int mins = (minutes % 60).round();
    
    if (hours > 0) {
      return '$hours hr ${mins > 0 ? '$mins min' : ''}';
    } else {
      return '$mins min';
    }
  }
}
