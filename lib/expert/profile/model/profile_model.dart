import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
    int? id;
    int? roleId;
    String? state;
    String? taluka;
    String? district;
    String? pincode;
    String? whatsappNumber;
    String? name;
    String? village;
    String? image;
    String? subscription;
    dynamic subscriptionExpiry;
    bool? isAccountSetup;

    ProfileModel({
        this.id,
        this.roleId,
        this.state,
        this.taluka,
        this.district,
        this.pincode,
        this.whatsappNumber,
        this.name,
        this.village,
        this.image,
        this.subscription,
        this.subscriptionExpiry,
        this.isAccountSetup,
    });

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json["id"],
        roleId: json["role_id"],
        state: json["state"],
        taluka: json["taluka"],
        district: json["district"],
        pincode: json["pincode"],
        whatsappNumber: json["whatsapp_number"],
        name: json["name"],
        village: json["village"],
        image: json["image"],
        subscription: json["subscription"],
        subscriptionExpiry: json["subscription_expiry"],
        isAccountSetup: json["isAccountSetup"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "role_id": roleId,
        "state": state,
        "taluka": taluka,
        "district": district,
        "pincode": pincode,
        "whatsapp_number": whatsappNumber,
        "name": name,
        "village": village,
        "image": image,
        "subscription": subscription,
        "subscription_expiry": subscriptionExpiry,
        "isAccountSetup": isAccountSetup,
    };
}
