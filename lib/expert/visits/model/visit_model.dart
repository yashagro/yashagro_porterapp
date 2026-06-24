import 'package:partener_app/models/user_model.dart';

class VisitModel {
  int? id;
  int? requestId;
  int? employeeId;
  int? farmerId;
  int? plotId;
  String? source;
  String? status;
  String? scheduledAt;
  String? onTheWayAt;
  String? arrivedAt;
  String? startedAt;
  String? completedAt;
  String? cancelledAt;
  int? travelMinutes;
  int? visitMinutes;
  String? totalDistanceKm;
  String? remarks;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? plotName;
  String? location;
  String? farmerName;
  String? farmerMobile;
  String? village;
  String? taluka;
  String? reason;

  VisitModel({
    this.id,
    this.requestId,
    this.employeeId,
    this.farmerId,
    this.plotId,
    this.source,
    this.status,
    this.scheduledAt,
    this.onTheWayAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.travelMinutes,
    this.visitMinutes,
    this.totalDistanceKm,
    this.remarks,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.plotName,
    this.location,
    this.farmerName,
    this.farmerMobile,
    this.village,
    this.taluka,
    this.reason,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'],
      requestId: json['request_id'],
      employeeId: json['employee_id'],
      farmerId: json['farmer_id'],
      plotId: json['plot_id'],
      source: json['source'],
      status: json['status'],
      scheduledAt: json['scheduled_at'],
      onTheWayAt: json['on_the_way_at'],
      arrivedAt: json['arrived_at'],
      startedAt: json['started_at'],
      completedAt: json['completed_at'],
      cancelledAt: json['cancelled_at'],
      travelMinutes: json['travel_minutes'],
      visitMinutes: json['visit_minutes'],
      totalDistanceKm: json['total_distance_km']?.toString(),
      remarks: json['remarks'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      plotName: json['plot_name'],
      location: json['location'],
      farmerName: json['farmer_name'],
      farmerMobile: json['farmer_mobile'],
      village: json['village'],
      taluka: json['taluka'],
      reason: json['reason'],
    );
  }
}

class VisitStatusHistoryModel {
  int? id;
  int? visitId;
  String? status;
  String? remarks;
  String? createdAt;

  VisitStatusHistoryModel({
    this.id,
    this.visitId,
    this.status,
    this.remarks,
    this.createdAt,
  });

  factory VisitStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return VisitStatusHistoryModel(
      id: json['id'],
      visitId: json['visit_id'],
      status: json['status'],
      remarks: json['remarks'],
      createdAt: json['created_at'],
    );
  }
}
