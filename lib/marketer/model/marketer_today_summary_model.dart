class MarketerTodaySummaryModel {
  final int id;
  final String status;
  final String scheduledAt;
  final int travelMinutes;
  final int visitMinutes;
  final int plotId;

  const MarketerTodaySummaryModel({
    required this.id,
    required this.status,
    required this.scheduledAt,
    required this.travelMinutes,
    required this.visitMinutes,
    required this.plotId,
  });

  factory MarketerTodaySummaryModel.fromJson(Map<String, dynamic> json) {
    return MarketerTodaySummaryModel(
      id: _parseInt(json['id']),
      status: (json['status'] ?? '').toString(),
      scheduledAt: (json['scheduled_at'] ?? '').toString(),
      travelMinutes: _parseInt(json['travel_minutes']),
      visitMinutes: _parseInt(json['visit_minutes']),
      plotId: _parseInt(json['plot_id']),
    );
  }

  String get formattedStatus {
    if (status.trim().isEmpty) {
      return 'Unknown';
    }

    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
