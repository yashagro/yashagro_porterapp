import 'package:latlong2/latlong.dart';

class MarketerDashboardModel {
  final int todayVisits;
  final int completedVisits;
  final int pendingVisits;
  final int travelMinutes;
  final int visitMinutes;
  final int workingMinutes;
  final String currentStatus;
  final Map<String, dynamic> currentLocation;

  const MarketerDashboardModel({
    required this.todayVisits,
    required this.completedVisits,
    required this.pendingVisits,
    required this.travelMinutes,
    required this.visitMinutes,
    required this.workingMinutes,
    required this.currentStatus,
    required this.currentLocation,
  });

  factory MarketerDashboardModel.fromJson(Map<String, dynamic> json) {
    return MarketerDashboardModel(
      todayVisits: _parseInt(json['today_visits']),
      completedVisits: _parseInt(json['completed_visits']),
      pendingVisits: _parseInt(json['pending_visits']),
      travelMinutes: _parseInt(json['travel_minutes']),
      visitMinutes: _parseInt(json['visit_minutes']),
      workingMinutes: _parseInt(json['working_minutes']),
      currentStatus: (json['current_status'] ?? '').toString(),
      currentLocation:
          json['current_location'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(json['current_location'])
              : <String, dynamic>{},
    );
  }

  String get formattedStatus {
    if (currentStatus.trim().isEmpty) return 'Unknown';
    return currentStatus
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String get currentLocationLabel {
    if (currentLocation.isEmpty) {
      return 'Location unavailable';
    }

    final latitude = currentLocation['latitude'] ?? currentLocation['lat'];
    final longitude = currentLocation['longitude'] ?? currentLocation['lng'];
    if (latitude != null && longitude != null) {
      return '$latitude, $longitude';
    }

    final location = currentLocation['location'];
    if (location != null && location.toString().isNotEmpty) {
      return location.toString();
    }

    return currentLocation.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
  }

  LatLng? get currentLatLng {
    final latitude = currentLocation['latitude'] ?? currentLocation['lat'];
    final longitude = currentLocation['longitude'] ?? currentLocation['lng'];

    final parsedLatitude = double.tryParse(latitude?.toString() ?? '');
    final parsedLongitude = double.tryParse(longitude?.toString() ?? '');

    if (parsedLatitude != null && parsedLongitude != null) {
      return LatLng(parsedLatitude, parsedLongitude);
    }

    final location = currentLocation['location']?.toString() ?? '';
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

  String get updatedAtLabel {
    final updatedAt = currentLocation['updated_at']?.toString() ?? '';
    if (updatedAt.isEmpty) {
      return 'Update time unavailable';
    }

    return updatedAt;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
