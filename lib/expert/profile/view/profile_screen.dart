import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/utils/app_routes.dart';
import 'package:partener_app/expert/profile/controller/profile_controller.dart';
import 'package:partener_app/expert/profile/model/profile_model.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileScreen({super.key});

  void logout() async {
    await SharedPrefs.clearUserData();
    Get.offAllNamed(AppRoutes.login);
  }

  void openEditDialog(BuildContext context) {
    final profile = controller.profile.value!;
    TextEditingController name = TextEditingController(
      text: profile.name ?? '',
    );
    TextEditingController mobile = TextEditingController(
      text: profile.whatsappNumber ?? '',
    );
    TextEditingController village = TextEditingController(
      text: profile.village ?? '',
    );
    TextEditingController taluka = TextEditingController(
      text: profile.taluka ?? '',
    );
    TextEditingController district = TextEditingController(
      text: profile.district ?? '',
    );
    TextEditingController state = TextEditingController(
      text: profile.state ?? '',
    );
    TextEditingController pincode = TextEditingController(
      text: profile.pincode ?? '',
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Color(0xFFFAF9F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GetBuilder<ProfileController>(
                  builder: (controller) {
                    return GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          controller.selectedImage = File(pickedFile.path);
                          controller
                              .update(); // ✅ Only update inside GetBuilder
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            controller.selectedImage != null
                                ? FileImage(controller.selectedImage!)
                                : (profile.image != null
                                        ? NetworkImage(ApiRoutes.baseUri+profile.image!)
                                        : AssetImage(
                                          "assets/default_profile.png",
                                        ))
                                    as ImageProvider,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField("Name", name),
                _buildTextField("Mobile No", mobile),
                _buildTextField("Village", village),
                _buildTextField("Taluka", taluka),
                _buildTextField("District", district),
                _buildTextField("State", state),
                _buildTextField("Pincode", pincode),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                ProfileModel updated = ProfileModel(
                  roleId: profile.roleId,
                  name: name.text,
                  whatsappNumber: mobile.text,
                  village: village.text,
                  taluka: taluka.text,
                  district: district.text,
                  state: state.text,
                  pincode: pincode.text,
                  isAccountSetup: profile.isAccountSetup ?? false,
                );
                await controller.updateProfile(updated);
                Get.back();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchProfile();

    return Scaffold(
      backgroundColor: Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFFAF9F6),
        centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value)
            return Center(child: CircularProgressIndicator());
          final profile = controller.profile.value;
          if (profile == null) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Profile not found",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  _button("LOGOUT", Colors.red, logout),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        profile.image != null
                            ? NetworkImage(ApiRoutes.baseUri+profile.image!)
                            : AssetImage("assets/default_profile.png")
                                as ImageProvider,
                  ),
                ),
                SizedBox(height: 30),

                _buildInfoRow("Name", profile.name),
                _buildInfoRow("Mobile No", profile.whatsappNumber),
                _buildInfoRow("Village", profile.village),
                _buildInfoRow("Taluka", profile.taluka),
                _buildInfoRow("District", profile.district),
                _buildInfoRow("State", profile.state),
                _buildInfoRow("Pincode", profile.pincode),

                SizedBox(height: 40),

                _button(
                  "EDIT PROFILE",
                  Colors.green,
                  () => openEditDialog(context),
                ),
                SizedBox(height: 12),
                _button("LOGOUT", Colors.red, logout),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$title:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value ?? '-',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
        ),
      ),
    );
  }
}
