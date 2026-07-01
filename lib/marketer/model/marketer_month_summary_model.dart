class MarketerMonthSummaryModel {
  final int totalVisits;
  final int completedVisits;
  final int totalTravelMinutes;
  final int totalVisitMinutes;

  const MarketerMonthSummaryModel({
    required this.totalVisits,
    required this.completedVisits,
    required this.totalTravelMinutes,
    required this.totalVisitMinutes,
  });

  factory MarketerMonthSummaryModel.fromJson(Map<String, dynamic> json) {
    return MarketerMonthSummaryModel(
      totalVisits: _parseInt(json['total_visits']),
      completedVisits: _parseInt(json['completed_visits']),
      totalTravelMinutes: _parseInt(json['total_travel_minutes']),
      totalVisitMinutes: _parseInt(json['total_visit_minutes']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
