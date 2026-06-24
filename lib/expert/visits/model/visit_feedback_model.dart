class VisitFeedbackModel {
  int? id;
  int? visitId;
  String? feedback;
  String? recommendation;
  String? cropCondition;
  String? nextVisitDate;
  String? createdAt;
  String? updatedAt;

  VisitFeedbackModel({
    this.id,
    this.visitId,
    this.feedback,
    this.recommendation,
    this.cropCondition,
    this.nextVisitDate,
    this.createdAt,
    this.updatedAt,
  });

  factory VisitFeedbackModel.fromJson(Map<String, dynamic> json) {
    return VisitFeedbackModel(
      id: json['id'],
      visitId: json['visit_id'],
      feedback: json['feedback'],
      recommendation: json['recommendation'],
      cropCondition: json['crop_condition'],
      nextVisitDate: json['next_visit_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visit_id': visitId,
      'feedback': feedback,
      'recommendation': recommendation,
      'crop_condition': cropCondition,
      'next_visit_date': nextVisitDate,
    };
  }
}
