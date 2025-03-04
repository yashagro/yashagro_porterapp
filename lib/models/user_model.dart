class UserModel {
  final int id;
  final int roleId;
  final String name;
  final String? image;
  final String village;
  final String state;
  final String taluka;
  final String district;
  final String pincode;
  final String whatsappNumber;
  final String subscription;
  final bool isAccountSetup;

  UserModel({
    required this.id,
    required this.roleId,
    required this.name,
    this.image,
    required this.village,
    required this.state,
    required this.taluka,
    required this.district,
    required this.pincode,
    required this.whatsappNumber,
    required this.subscription,
    required this.isAccountSetup,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
