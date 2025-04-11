import 'package:flutter/material.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger.dart';
import 'package:zappis/widgets/bottom_sheets/payment_bottom_sheet.dart';
import 'package:zappis/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class BookingBottomSheet extends StatefulWidget {
  final Station station;
  final String? selectedChargerId;
  final double? currentBatteryPercentage;
  final double? targetBatteryPercentage;

  const BookingBottomSheet({
    super.key,
    required this.station,
    this.selectedChargerId,
    this.currentBatteryPercentage,
    this.targetBatteryPercentage,
  });

  static Future<void> show(
    BuildContext context,
    Station station, {
    String? selectedChargerId,
    double? currentBatteryPercentage,
    double? targetBatteryPercentage,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(
        station: station,
        selectedChargerId: selectedChargerId,
        currentBatteryPercentage: currentBatteryPercentage,
        targetBatteryPercentage: targetBatteryPercentage,
      ),
    );
  }

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  late Charger _selectedCharger;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  double _currentBatteryPercentage = 20;
  double _targetBatteryPercentage = 80;
  double _batteryCapacity = 60; // kWh

  double _chargingTime = 0;
  double _chargingCost = 0;
  int _selectedTabIndex = 0;

  List<Charger> get _fastChargers =>
      widget.station.chargers.where((c) => c.power >= 50).toList();
  List<Charger> get _standardChargers =>
      widget.station.chargers.where((c) => c.power < 50).toList();

  @override
  void initState() {
    super.initState();

    // Initialize selected charger
    if (widget.selectedChargerId != null) {
      _selectedCharger = widget.station.chargers.firstWhere(
        (charger) => charger.id == widget.selectedChargerId,
        orElse: () => widget.station.chargers.first,
      );
      _selectedTabIndex = _fastChargers.contains(_selectedCharger) ? 0 : 1;
    } else {
      // Default to first available charger type
      if (_fastChargers.isNotEmpty) {
        _selectedCharger = _fastChargers.first;
        _selectedTabIndex = 0;
      } else if (_standardChargers.isNotEmpty) {
        _selectedCharger = _standardChargers.first;
        _selectedTabIndex = 1;
      } else {
        // Fallback to first charger if no categorization
        _selectedCharger = widget.station.chargers.first;
        _selectedTabIndex = 0;
      }
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: const [
                            Tab(text: 'Fast Charging'),
                            Tab(text: 'Standard Charging'),
                          ],
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildChargerInfo(
                              Icons.attach_money,
                              'Estimated Cost',
                              '${_chargingCost.toStringAsFixed(2)} Birr',
                            ),
                            _buildChargerInfo(
                              Icons.timer,
                              'Charging Time',
                              _formatDuration(_chargingTime * 60),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildBatteryLevelSliders(),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Next',
                          onPressed: () {
                            _showDateTimeSelection(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateTimeSelection(BuildContext context) {
    // Implement the second bottom sheet for date and time selection
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Date & Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                      'Select Date: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Select Time: ${_selectedTime.format(context)}'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Next',
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showFinalConfirmation(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFinalConfirmation(BuildContext context) {
    // Implement the final confirmation sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildChargerDetails(),
              const SizedBox(height: 16),
              _buildSummary(),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Confirm & Pay',
                onPressed: () {
                  Navigator.of(context).pop();
                  PaymentBottomSheet.show(
                    context,
                    station: widget.station,
                    charger: _selectedCharger,
                    date: _selectedDate,
                    time: _selectedTime,
                    currentBatteryPercentage: _currentBatteryPercentage,
                    targetBatteryPercentage: _targetBatteryPercentage,
                    batteryCapacity: _batteryCapacity,
                    chargingTime: _chargingTime,
                    chargingCost: _chargingCost,
                  );
                },
              ),
            ],
          ),
        ),
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
            Icons.book_online,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Book Charging Session',
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

  Widget _buildBatteryLevelSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Battery Level',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Slider(
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
        const SizedBox(height: 16),
        const Text(
          'Target Battery Level',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Slider(
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
      ],
    );
  }

  Widget _buildChargerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charger Type: ${_selectedCharger.type} - ${_selectedCharger.power} kW',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Price: ${widget.station.price} Birr/kWh',
          style: const TextStyle(fontSize: 16),
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

  Widget _buildChargerInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChargerInfo(
          Icons.attach_money,
          'Total Cost',
          '${_chargingCost.toStringAsFixed(2)} Birr',
        ),
        const SizedBox(height: 8),
        _buildChargerInfo(
          Icons.timer,
          'Total Time',
          _formatDuration(_chargingTime * 60),
        ),
        const SizedBox(height: 8),
        _buildChargerInfo(
          Icons.battery_charging_full,
          'Battery Level',
          '${_currentBatteryPercentage.round()}% to ${_targetBatteryPercentage.round()}%',
        ),
      ],
    );
  }
}
