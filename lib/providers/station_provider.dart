import 'package:flutter/material.dart';
import '../models/station.dart';
import '../models/alert.dart';

class StationProvider extends ChangeNotifier {
  List<Station> _stations = [];
  List<Alert> _alerts = [];
  bool _isLoading = false;

  List<Station> get stations => _stations;
  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;

  Future<void> fetchStations() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      _stations = Station.getSampleStations();
    } catch (e) {
      debugPrint('Error fetching stations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Station> getStationById(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Find station in local cache
    final station = _stations.firstWhere(
      (station) => station.id == id,
      orElse: () => Station.getSampleStations().firstWhere(
        (station) => station.id == id,
        orElse: () => throw Exception('Station not found'),
      ),
    );

    return station;
  }

  Future<void> toggleFavorite(String stationId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _stations.indexWhere((station) => station.id == stationId);
      if (index != -1) {
        _stations[index] = _stations[index].copyWith(
          isFavorite: !_stations[index].isFavorite,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> fetchAlerts() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      _alerts = sampleAlerts;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
    }
  }

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

      _alerts.insert(0, newAlert);
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating alert: $e');
    }
  }

  void deleteAlert(String alertId) {
    _alerts.removeWhere((alert) => alert.id == alertId);
    notifyListeners();
  }
}
