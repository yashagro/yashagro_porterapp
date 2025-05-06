
import 'dart:convert';

FarmerPlotModel farmerPlotModelFromJson(String str) => FarmerPlotModel.fromJson(json.decode(str));

String farmerPlotModelToJson(FarmerPlotModel data) => json.encode(data.toJson());

class FarmerPlotModel {
    int? id;
    String? plotName;
    String? area;
    String? areaUnit;
    String? plantDistance;
    int? totalPlants;
    String? soilType;
    dynamic irrigationType;
    dynamic structure;
    String? location;
    String? soilPh;
    dynamic waterResource;
    String? ec;
    String? freelime;
    String? waterHoldingCapacity;
    String? startDate;
    dynamic plantationYear;
    bool? hasAccess;
    dynamic plantingDate;
    String? prunningDate;
    dynamic cuttingDate;
    User? user;
    Crop? crop;
    Variety? variety;
    Pruning? pruning;
    dynamic plantation;
    Target? target;

    FarmerPlotModel({
        this.id,
        this.plotName,
        this.area,
        this.areaUnit,
        this.plantDistance,
        this.totalPlants,
        this.soilType,
        this.irrigationType,
        this.structure,
        this.location,
        this.soilPh,
        this.waterResource,
        this.ec,
        this.freelime,
        this.waterHoldingCapacity,
        this.startDate,
        this.plantationYear,
        this.hasAccess,
        this.plantingDate,
        this.prunningDate,
        this.cuttingDate,
        this.user,
        this.crop,
        this.variety,
        this.pruning,
        this.plantation,
        this.target,
    });

    factory FarmerPlotModel.fromJson(Map<String, dynamic> json) => FarmerPlotModel(
        id: json["id"],
        plotName: json["plot_name"],
        area: json["area"],
        areaUnit: json["area_unit"],
        plantDistance: json["plant_distance"],
        totalPlants: json["total_plants"],
        soilType: json["soil_type"],
        irrigationType: json["irrigation_type"],
        structure: json["structure"],
        location: json["location"],
        soilPh: json["soil_ph"],
        waterResource: json["water_resource"],
        ec: json["ec"],
        freelime: json["freelime"],
        waterHoldingCapacity: json["water_holding_capacity"],
        startDate: json["start_date"],
        plantationYear: json["plantation_year"],
        hasAccess: json["has_access"],
        plantingDate: json["planting_date"],
        prunningDate: json["prunning_date"],
        cuttingDate: json["cutting_date"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        crop: json["crop"] == null ? null : Crop.fromJson(json["crop"]),
        variety: json["variety"] == null ? null : Variety.fromJson(json["variety"]),
        pruning: json["pruning"] == null ? null : Pruning.fromJson(json["pruning"]),
        plantation: json["plantation"],
        target: json["target"] == null ? null : Target.fromJson(json["target"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "plot_name": plotName,
        "area": area,
        "area_unit": areaUnit,
        "plant_distance": plantDistance,
        "total_plants": totalPlants,
        "soil_type": soilType,
        "irrigation_type": irrigationType,
        "structure": structure,
        "location": location,
        "soil_ph": soilPh,
        "water_resource": waterResource,
        "ec": ec,
        "freelime": freelime,
        "water_holding_capacity": waterHoldingCapacity,
        "start_date": startDate,
        "plantation_year": plantationYear,
        "has_access": hasAccess,
        "planting_date": plantingDate,
        "prunning_date": prunningDate,
        "cutting_date": cuttingDate,
        "user": user?.toJson(),
        "crop": crop?.toJson(),
        "variety": variety?.toJson(),
        "pruning": pruning?.toJson(),
        "plantation": plantation,
        "target": target?.toJson(),
    };
}

class Crop {
    int? id;
    String? cropName;
    String? file;

    Crop({
        this.id,
        this.cropName,
        this.file,
    });

    factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json["id"],
        cropName: json["crop_name"],
        file: json["file"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "crop_name": cropName,
        "file": file,
    };
}

class Pruning {
    int? id;
    String? pruningType;

    Pruning({
        this.id,
        this.pruningType,
    });

    factory Pruning.fromJson(Map<String, dynamic> json) => Pruning(
        id: json["id"],
        pruningType: json["pruning_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "pruning_type": pruningType,
    };
}

class Target {
    int? id;
    String? target;

    Target({
        this.id,
        this.target,
    });

    factory Target.fromJson(Map<String, dynamic> json) => Target(
        id: json["id"],
        target: json["target"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "target": target,
    };
}

class User {
    int? id;
    String? name;

    User({
        this.id,
        this.name,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class Variety {
    int? id;
    String? variety;

    Variety({
        this.id,
        this.variety,
    });

    factory Variety.fromJson(Map<String, dynamic> json) => Variety(
        id: json["id"],
        variety: json["variety"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "variety": variety,
    };
}
