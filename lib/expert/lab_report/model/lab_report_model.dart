// To parse this JSON data, do
//
//     final labReportModel = labReportModelFromJson(jsonString);

import 'dart:convert';

LabReportModel labReportModelFromJson(String str) => LabReportModel.fromJson(json.decode(str));

String labReportModelToJson(LabReportModel data) => json.encode(data.toJson());

class LabReportModel {
    Labreport? labreport;
    Plot? plot;
    Crop? crop;
    User? user;

    LabReportModel({
        this.labreport,
        this.plot,
        this.crop,
        this.user,
    });

    factory LabReportModel.fromJson(Map<String, dynamic> json) => LabReportModel(
        labreport: json["labreport"] == null ? null : Labreport.fromJson(json["labreport"]),
        plot: json["plot"] == null ? null : Plot.fromJson(json["plot"]),
        crop: json["crop"] == null ? null : Crop.fromJson(json["crop"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "labreport": labreport?.toJson(),
        "plot": plot?.toJson(),
        "crop": crop?.toJson(),
        "user": user?.toJson(),
    };
}

class Crop {
    int? id;
    String? cropName;
    String? cropImage;

    Crop({
        this.id,
        this.cropName,
        this.cropImage,
    });

    factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json["id"],
        cropName: json["crop_name"],
        cropImage: json["crop_image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "crop_name": cropName,
        "crop_image": cropImage,
    };
}

class Labreport {
    int? id;
    String? title;
    String? fileUrl;
    String? expiry;
    String? type;
    String? createdAt;
    String? updatedAt;

    Labreport({
        this.id,
        this.title,
        this.fileUrl,
        this.expiry,
        this.type,
        this.createdAt,
        this.updatedAt,
    });

    factory Labreport.fromJson(Map<String, dynamic> json) => Labreport(
        id: json["id"],
        title: json["title"],
        fileUrl: json["file_url"],
        expiry: json["expiry"],
        type: json["type"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "file_url": fileUrl,
        "expiry": expiry,
        "type": type,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}

class Plot {
    int? id;
    String? plotName;
    int? variety;
    String? area;
    String? areaUnit;

    Plot({
        this.id,
        this.plotName,
        this.variety,
        this.area,
        this.areaUnit,
    });

    factory Plot.fromJson(Map<String, dynamic> json) => Plot(
        id: json["id"],
        plotName: json["plot_name"],
        variety: json["variety"],
        area: json["area"],
        areaUnit: json["area_unit"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "plot_name": plotName,
        "variety": variety,
        "area": area,
        "area_unit": areaUnit,
    };
}

class User {
    int? id;
    String? name;
    int? roleId;
    String? mobileNo;

    User({
        this.id,
        this.name,
        this.roleId,
        this.mobileNo,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        roleId: json["role_id"],
        mobileNo: json["mobile_no"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "role_id": roleId,
        "mobile_no": mobileNo,
    };
}
