
import 'dart:convert';

WorkDiarieModel workDiarieModelFromJson(String str) => WorkDiarieModel.fromJson(json.decode(str));

String workDiarieModelToJson(WorkDiarieModel data) => json.encode(data.toJson());

class WorkDiarieModel {
    int? id;
    int? plotId;
    int? userId;
    int? day;
    String? activity;
    String? status;
    String? income;
    String? expense;
    String? date;
    String? feedback;
    String? createdAt;
    String? updatedAt;

    WorkDiarieModel({
        this.id,
        this.plotId,
        this.userId,
        this.day,
        this.activity,
        this.status,
        this.income,
        this.expense,
        this.date,
        this.feedback,
        this.createdAt,
        this.updatedAt,
    });

    factory WorkDiarieModel.fromJson(Map<String, dynamic> json) => WorkDiarieModel(
        id: json["id"],
        plotId: json["plot_id"],
        userId: json["user_id"],
        day: json["day"],
        activity: json["activity"],
        status: json["status"],
        income: json["income"],
        expense: json["expense"],
        date: json["date"],
        feedback: json["feedback"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "plot_id": plotId,
        "user_id": userId,
        "day": day,
        "activity": activity,
        "status": status,
        "income": income,
        "expense": expense,
        "date": date,
        "feedback": feedback,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}
