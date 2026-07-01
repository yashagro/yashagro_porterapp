import 'package:latlong2/latlong.dart';

class MarketerRouteHistoryModel {
  final String location;
  final double accuracy;
  final double speed;
  final int batteryPercentage;
  final String recordedAt;

  const MarketerRouteHistoryModel({
    required this.location,
    required this.accuracy,
    required this.speed,
    required this.batteryPercentage,
    required this.recordedAt,
  });

  factory MarketerRouteHistoryModel.fromJson(Map<String, dynamic> json) {
    return MarketerRouteHistoryModel(
      location: (json['location'] ?? '').toString(),
      accuracy: _parseDouble(json['accuracy']),
      speed: _parseDouble(json['speed']),
      batteryPercentage: _parseInt(json['battery_percentage']),
      recordedAt: (json['recorded_at'] ?? '').toString(),
    );
  }

  LatLng? get latLng {
    if (location.isEmpty) {
      return null;
    }

    final parts = location.split(',');
    if (parts.length != 2) {
      return null;
    }

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) {
      return null;
    }

    return LatLng(lat, lng);
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
