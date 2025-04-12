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
      _selectedCharger = _fastChargers.isNotEmpty
          ? _fastChargers.first
          : _standardChargers.first;
      _selectedTabIndex = _fastChargers.isNotEmpty ? 0 : 1;
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
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: DefaultTabController(
              length: 2,
              initialIndex: _selectedTabIndex,
              child: Column(
                children: [
                  TabBar(
                    onTap: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                        _selectedCharger =
                            index == 0 && _fastChargers.isNotEmpty
                                ? _fastChargers.first
                                : _standardChargers.first;
                        _calculateChargingDetails();
                      });
                    },
                    tabs: const [
                      Tab(text: 'Fast Charging'),
                      Tab(text: 'Standard Charging'),
                    ],
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildChargersList(),
                          const SizedBox(height: 16),
                          _buildBatteryLevelSliders(),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildChargerInfo(
                                Icons.timer,
                                'Duration',
                                _formatDuration(_chargingTime * 60),
                              ),
                              _buildChargerInfo(
                                Icons.attach_money,
                                'Cost',
                                '${_chargingCost.toStringAsFixed(2)} Birr',
                              ),
                            ],
                          ),
                          const Spacer(),
                          CustomButton(
                            text: 'Next',
                            onPressed: () => _showDateTimeSelection(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateTimeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader('Select Date & Time'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select Time',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSummary(),
                    const Spacer(),
                    CustomButton(
                      text: 'Next',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showConfirmation(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader('Confirm Booking'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChargerDetails(),
                    const SizedBox(height: 24),
                    _buildSummary(),
                    const Spacer(),
                    CustomButton(
                      text: 'Proceed to Payment',
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader([String? title]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Icon(
            title == null ? Icons.book_online : Icons.arrow_back,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            title ?? 'Book Charging Session',
            style: const TextStyle(
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

  Widget _buildChargersList() {
    final chargers = _selectedTabIndex == 0 ? _fastChargers : _standardChargers;
    final prefix = _selectedTabIndex == 0 ? 'Fast' : 'Standard';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Chargers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...chargers.map((charger) => RadioListTile<Charger>(
              title: Text('$prefix - ${charger.type} - ${charger.power} kW'),
              value: charger,
              groupValue: _selectedCharger,
              onChanged: (Charger? value) {
                if (value != null) {
                  setState(() {
                    _selectedCharger = value;
                    _calculateChargingDetails();
                  });
                }
              },
            )),
      ],
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
    final prefix = _selectedCharger.power >= 50 ? 'Fast' : 'Standard';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charger Type: $prefix - ${_selectedCharger.type} - ${_selectedCharger.power} kW',
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
