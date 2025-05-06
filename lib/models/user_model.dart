class UserModel {
  final int? id;
  final int? roleId;
  final String? name;
  final String? image;
  final String? village;
  final String? state;
  final String? taluka;
  final String? district;
  final String? pincode;
  final String? whatsappNumber;
  final String? subscription;
  final bool? isAccountSetup;
  final String? email;
  final String? mobileNo;

  UserModel({
    this.id,
    this.roleId,
    this.name,
    this.image,
    this.village,
    this.state,
    this.taluka,
    this.district,
    this.pincode,
    this.whatsappNumber,
    this.subscription,
    this.isAccountSetup,
    this.email,
    this.mobileNo,
  });

  factory UserModel.fromJson(Map<String?, dynamic> json) {
    return UserModel(
      id: json['id'],
      roleId: json['role_id'],
      name: json['name'],
      image: json['image'],
      village: json['village'],
      state: json['state'],
      taluka: json['taluka'],
      district: json['district'],
      pincode: json['pincode'],
      whatsappNumber: json['whatsapp_number'],
      subscription: json['subscription'],
      isAccountSetup: json['isAccountSetup'],
      mobileNo: json['mobile_no'],
      email: json['email'],
    );
  }
}
