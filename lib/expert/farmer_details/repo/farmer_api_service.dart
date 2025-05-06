import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:partener_app/services/shared_prefs.dart';

class FarmerApiService {
  final Dio _dio = Dio();
  final String baseUrl = "$baseUri";

  /// Fetch User Profile
  Future<UserModel?> fetchUserProfile() async {
    try {
      log("🔹 Fetching User Profile...");
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) return null;

      Response response = await _dio.get(
        "$baseUrl/api/auth/profile",
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }

      log("⚠️ Failed to fetch user profile: ${response.data}");
      return null;
    } catch (e) {
      log("❌ Error Fetching User Profile: $e");
      return null;
    }
  }

  /// Fetch Basic Plot Details
  Future<Map<String, dynamic>?> fetchPlotDetails(int plotId) async {
    try {
      log("🔹 Fetching Plot Details for Plot ID: $plotId");

      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null || authToken.isEmpty) return null;

      String apiUrl = "$baseUrl/api/plots/$plotId";

      Response response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $authToken",
            "Content-Type": "application/json",
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return _extractBasicPlotDetails(response.data['data']);
      }

      return null;
    } catch (e) {
      log("❌ Exception Fetching Plot Details: $e");
      return null;
    }
  }

  Map<String, dynamic> _extractBasicPlotDetails(Map<String, dynamic> plotData) {
    return {
      "id": plotData["id"],
      "plot_name": plotData["plot_name"] ?? "N/A",
      "crops_id": plotData["crops_id"] ?? "N/A",
      "variety": plotData["variety"] ?? "N/A",
      "area": plotData["area"] ?? "N/A",
      "area_unit": plotData["area_unit"] ?? "N/A",
      "soil_type": plotData["soil_type"] ?? "N/A",
      "location": plotData["location"] ?? "N/A",
      "structure": plotData["structure"] ?? "N/A",
    };
  }

  /// Fetch Full Plot Details
  Future<Map<String, dynamic>?> fetchPlotFullDetails(int plotId) async {
    try {
      log("🔹 Fetching Full Plot Details for Plot ID: $plotId");

      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null || authToken.isEmpty) return null;

      String apiUrl = "$baseUrl/api/plots-details/$plotId";

      Response response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $authToken",
            "Content-Type": "application/json",
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }

      return null;
    } catch (e) {
      log("❌ Error Fetching Full Plot Details: $e");
      return null;
    }
  }

  /// Fetch Crops
  Future<Map<int, String>?> fetchCrops() async {
    try {
      log("🔹 Fetching Crops List...");
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) return null;

      Response response = await _dio.get(
        "$baseUrl/api/crops",
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> crops = response.data['data'];
        return {for (var crop in crops) crop['id']: crop['name']};
      }

      log("⚠️ Failed to fetch crops: ${response.data}");
      return null;
    } catch (e) {
      log("❌ Error Fetching Crops: $e");
      return null;
    }
  }

  /// Fetch Crop Varieties
  Future<Map<int, String>?> fetchCropVarieties(int cropId) async {
    try {
      log("🔹 Fetching Varieties for Crop ID: $cropId");
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) return null;

      Response response = await _dio.get(
        "$baseUrl/api/crops/crop-varieties/$cropId",
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> varieties = response.data['data'];
        return {for (var v in varieties) v['id']: v['name']};
      }

      log("⚠️ Failed to fetch crop varieties: ${response.data}");
      return null;
    } catch (e) {
      log("❌ Error Fetching Crop Varieties: $e");
      return null;
    }
  }

  /// Fetch Pruning Types
  Future<Map<int, String>?> fetchPruningTypes() async {
    try {
      log("🔹 Fetching Pruning Types...");
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) return null;

      Response response = await _dio.get(
        "$baseUrl/api/crops/pruningtype",
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> types = response.data['data'];
        return {for (var t in types) t['id']: t['name']};
      }

      log("⚠️ Failed to fetch pruning types: ${response.data}");
      return null;
    } catch (e) {
      log("❌ Error Fetching Pruning Types: $e");
      return null;
    }
  }

  /// Fetch Plantation Types
  Future<Map<int, String>?> fetchPlantationTypes() async {
    try {
      log("🔹 Fetching Plantation Types...");
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) return null;

      Response response = await _dio.get(
        "$baseUrl/api/crops/plantation",
        options: Options(headers: {
          "Authorization": "Bearer $authToken",
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> types = response.data['data'];
        return {for (var t in types) t['id']: t['name']};
      }

      log("⚠️ Failed to fetch plantation types: ${response.data}");
      return null;
    } catch (e) {
      log("❌ Error Fetching Plantation Types: $e");
      return null;
    }
  }
}
