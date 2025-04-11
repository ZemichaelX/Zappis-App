import 'package:flutter/material.dart';
import '../models/alert.dart';

class AlertProvider extends ChangeNotifier {
  List<Alert> _alerts = [];
  bool _isLoading = false;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;

  Future<void> fetchAlerts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      _alerts = sampleAlerts;
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _alerts.removeWhere((alert) => alert.id == alertId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting alert: $e');
    }
  }

  Future<void> markAlertAsRead(String alertId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _alerts.indexWhere((alert) => alert.id == alertId);
      if (index != -1) {
        _alerts[index] = _alerts[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking alert as read: $e');
    }
  }

  // Add a method to create a new alert
  Future<void> createAlert({
    required String stationId,
    required String stationName,
    required String type,
    required String message,
    required List<String> chargerTypes,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final newAlert = Alert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stationId: stationId,
        stationName: stationName,
        type: type,
        message: message,
        createdAt: DateTime.now(),
        isRead: false,
        chargerTypes: chargerTypes,
      );

      _alerts.insert(0, newAlert); // Add to the beginning of the list
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating alert: $e');
    }
  }
}
