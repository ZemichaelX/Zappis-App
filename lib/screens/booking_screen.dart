import 'package:flutter/material.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger.dart';
import 'package:zappis/screens/payment_screen.dart';
import 'package:zappis/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Station station;
  final String? selectedChargerId;
  final double? currentBatteryPercentage;
  final double? targetBatteryPercentage;

  const BookingScreen({
    super.key,
    required this.station,
    this.selectedChargerId,
    this.currentBatteryPercentage,
    this.targetBatteryPercentage,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Charger _selectedCharger;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  double _currentBatteryPercentage = 20;
  double _targetBatteryPercentage = 80;
  double _batteryCapacity = 60; // kWh

  double _chargingTime = 0;
  double _chargingCost = 0;

  @override
  void initState() {
    super.initState();

    // Initialize selected charger
    if (widget.selectedChargerId != null) {
      _selectedCharger = widget.station.chargers.firstWhere(
        (charger) => charger.id == widget.selectedChargerId,
        orElse: () => widget.station.chargers.first,
      );
    } else {
      _selectedCharger = widget.station.chargers.first;
    }

    // Initialize battery percentages if provided
    if (widget.currentBatteryPercentage != null) {
      _currentBatteryPercentage = widget.currentBatteryPercentage!;
    }

    if (widget.targetBatteryPercentage != null) {
      _targetBatteryPercentage = widget.targetBatteryPercentage!;
    }

    // Initialize date and time
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();

    // Add 1 hour to current time
    final now = DateTime.now();
    _selectedTime = TimeOfDay(
      hour: (now.hour + 1) % 24,
      minute: now.minute,
    );

    _calculateChargingDetails();
  }

  void _calculateChargingDetails() {
    // Calculate energy needed in kWh
    final energyNeeded = _batteryCapacity *
        (_targetBatteryPercentage - _currentBatteryPercentage) /
        100;

    // Calculate charging time in hours
    _chargingTime = energyNeeded / _selectedCharger.power;

    // Calculate cost in Birr
    _chargingCost = energyNeeded * widget.station.price;

    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Charging Session'),
      ),
      body: SingleChildScrollView(
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: widget.station.chargers.map((charger) {
                return DropdownMenuItem<Charger>(
                  value: charger,
                  child: Text('${charger.type} - ${charger.power} kW'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCharger = value;
                  });
                  _calculateChargingDetails();
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Date & Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _selectedTime.format(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Battery Details',
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
                labelText: 'Battery Capacity',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            const SizedBox(height: 16),
            const Text(
              'Current Battery Percentage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
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
                        if (_currentBatteryPercentage >=
                            _targetBatteryPercentage) {
                          _targetBatteryPercentage =
                              _currentBatteryPercentage + 5;
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
            const SizedBox(height: 8),
            const Text(
              'Target Battery Percentage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
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
                        if (_targetBatteryPercentage <=
                            _currentBatteryPercentage) {
                          _currentBatteryPercentage =
                              _targetBatteryPercentage - 5;
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
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Date',
                      DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Time',
                      _selectedTime.format(context),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Charger',
                      '${_selectedCharger.type} - ${_selectedCharger.power} kW',
                    ),
                    const SizedBox(height: 8),
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
              text: 'Proceed to Payment',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      station: widget.station,
                      charger: _selectedCharger,
                      date: _selectedDate,
                      time: _selectedTime,
                      currentBatteryPercentage: _currentBatteryPercentage,
                      targetBatteryPercentage: _targetBatteryPercentage,
                      batteryCapacity: _batteryCapacity,
                      chargingTime: _chargingTime,
                      chargingCost: _chargingCost,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
