import 'dart:io';
import 'package:get/get.dart';
import 'package:partener_app/expert/profile/repo/expert_profile_service.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();

  Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  RxBool isLoading = false.obs;
  File? selectedImage;

  /// Load profile from API
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final result = await _service.fetchProfile();
      profile.value = result;
      print("✅ Profile fetched successfully");
    } catch (e) {
      print("❌ Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Update profile with optional image
  Future<void> updateProfile(ProfileModel updatedData) async {
    try {
      isLoading.value = true;
      bool success = await _service.updateProfile(
        updatedData,
        image: selectedImage,
      );
      if (success) {
        print("✅ Profile updated successfully");
        await fetchProfile();
      } else {
        print("⚠️ Failed to update profile");
      }
    } catch (e) {
      print("❌ Error updating profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear selected image
  void clearSelectedImage() {
    selectedImage = null;
    update();
  }
}
