import 'package:flutter/material.dart';
import 'package:zappis/models/station.dart';
import 'package:zappis/models/charger.dart';
import 'package:zappis/widgets/bottom_sheets/payment_success_bottom_sheet.dart';
import 'package:zappis/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentBottomSheet extends StatefulWidget {
  final Station station;
  final Charger charger;
  final DateTime date;
  final TimeOfDay time;
  final double currentBatteryPercentage;
  final double targetBatteryPercentage;
  final double batteryCapacity;
  final double chargingTime;
  final double chargingCost;

  const PaymentBottomSheet({
    super.key,
    required this.station,
    required this.charger,
    required this.date,
    required this.time,
    required this.currentBatteryPercentage,
    required this.targetBatteryPercentage,
    required this.batteryCapacity,
    required this.chargingTime,
    required this.chargingCost,
  });

  static Future<void> show(
    BuildContext context, {
    required Station station,
    required Charger charger,
    required DateTime date,
    required TimeOfDay time,
    required double currentBatteryPercentage,
    required double targetBatteryPercentage,
    required double batteryCapacity,
    required double chargingTime,
    required double chargingCost,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentBottomSheet(
        station: station,
        charger: charger,
        date: date,
        time: time,
        currentBatteryPercentage: currentBatteryPercentage,
        targetBatteryPercentage: targetBatteryPercentage,
        batteryCapacity: batteryCapacity,
        chargingTime: chargingTime,
        chargingCost: chargingCost,
      ),
    );
  }

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  bool _isLoading = false;
  String _paymentMethod = 'santimpay';

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.of(context).pop();
      PaymentSuccessBottomSheet.show(
        context,
        station: widget.station,
        charger: widget.charger,
        date: widget.date,
        time: widget.time,
        chargingTime: widget.chargingTime,
        chargingCost: widget.chargingCost,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );

      setState(() {
        _isLoading = false;
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
                          const Text(
                            'Booking Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            'Station',
                            widget.station.name,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Date & Time',
                            '${DateFormat('EEE, MMM d, yyyy').format(widget.date)} at ${widget.time.format(context)}',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Charger',
                            '${widget.charger.type} - ${widget.charger.power} kW',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Charging',
                            '${widget.currentBatteryPercentage.round()}% to ${widget.targetBatteryPercentage.round()}%',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Estimated Time',
                            _formatDuration(widget.chargingTime * 60),
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            'Total Amount',
                            '${widget.chargingCost.toStringAsFixed(2)} Birr',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/images/santimpay.png',
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 12),
                              const Text('SantimPay'),
                            ],
                          ),
                          value: 'santimpay',
                          groupValue: _paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/images/telebirr.png',
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 12),
                              const Text('TeleBirr'),
                            ],
                          ),
                          value: 'telebirr',
                          groupValue: _paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/images/cbe.png',
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 12),
                              const Text('CBE Birr'),
                            ],
                          ),
                          value: 'cbe',
                          groupValue: _paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Scan QR Code to Pay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: QrImageView(
                      data:
                          'zappis-payment:${widget.station.id}:${widget.charger.id}:${widget.chargingCost.toStringAsFixed(2)}',
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Open your SantimPay app and scan this code',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Confirm Payment',
                    isLoading: _isLoading,
                    onPressed: _processPayment,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.help_outline),
                      label: const Text('Need help with payment?'),
                      onPressed: () {
                        // Show payment help dialog
                      },
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
            Icons.payment,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Payment',
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
