import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart' show ApiRoutes;
import 'package:partener_app/models/chats_model.dart';
import 'package:partener_app/models/pagination_model.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = ApiRoutes.baseUri;

  Future<bool> sendOtp(String mobile) async {
    try {
      Response response = await _dio.post(
        "$baseUrl${ApiRoutes.sendOtpEndpoint}",
        data: {"mobile_no": mobile},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Send OTP Error: $e");
      return false;
    }
  }

  /// **Verify OTP API Call (With Player ID)**
  Future<Map<String, dynamic>?> verifyOtp(String mobile, String otp) async {
    try {
      String? playerId = await SharedPrefs.getOneSignalPlayerID();

      print("🔹 Sending OTP Verification Request with Player ID: $playerId");

      // ✅ Make API Call with Player ID
      final response = await _dio.post(
        "$baseUrl${ApiRoutes.verifyOtpEndpoint}",
        data: {
          "mobile_no": mobile,
          "otp": otp,
          "device_id": playerId, // ✅ Pass OneSignal Player ID
        },
      );

      // ✅ Handle Success Response
      if (response.statusCode == 200 && response.data != null) {
        print("✅ OTP API Response: ${response.data}");
        return response.data; // ✅ Return full API response
      }

      // ❌ Handle API Failure
      print("⚠️ OTP Verification Failed: ${response.statusMessage}");
      return null;
    } catch (e) {
      // ❌ Handle Network/Server Errors
      print("❌ API Error (verifyOtp): $e");

      if (e is DioException) {
        print("⚠️ DioException: ${e.message}");
      }

      return null;
    }
  }

  /// **Fetch User Profile**
  Future<UserModel?> fetchUserProfile() async {
    try {
      print("🔹 Fetching User Profile...");

      // **Retrieve Auth Token from Local Storage**
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) {
        print("❌ Error: No Auth Token Found");
        return null;
      }

      // **API Request**
      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.userProfileEndpoint}",
        options: Options(
          headers: {
            "Authorization": "Bearer $authToken",
            "Content-Type": "application/json",
          },
        ),
      );

      print("✅ API Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        var userData = response.data['data'];

        // ✅ Extract Only Required Fields
        // Map<String, dynamic> extractedUserData = {
        //   "id": userData["id"],
        //   "name": userData["name"] ?? "N/A",
        //   "email": userData["email"] ?? "N/A",
        //   "mobile_no": userData["mobile_no"] ?? "N/A",
        //   "profile_pic": userData["profile_pic"] ?? "",
        //   "role": userData["role"] ?? "N/A",
        //   "created_at": userData["createdAt"] ?? "N/A",
        // };

        return UserModel.fromJson(userData);
      } else {
        print("⚠️ Failed to fetch user profile: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error Fetching User Profile: $e");
      return null;
    }
  }

  /// **Fetch Expert Chat Rooms**

  /// **Fetch Chat History with Pagination**
  Future<PaginatedResult<ChatsModel>?> fetchChatHistory(
    int roomId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.chatHistoryEndpoint}$roomId?limit=$limit&page=$page",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        final dynamic rawData = response.data['data'];
        List<ChatsModel> chats = [];
        PaginationModel? pagination;

        if (rawData is Map<String, dynamic>) {
          // New Paginated structure: { "data": [...], "pagination": {...} }
          final List dataList = rawData['data'] ?? [];
          chats = dataList.map((json) => ChatsModel.fromJson(json)).toList();
          pagination =
              rawData['pagination'] != null
                  ? PaginationModel.fromJson(rawData['pagination'])
                  : null;
        } else if (rawData is List) {
          // Old flat structure: [ ... ]
          chats = rawData.map((json) => ChatsModel.fromJson(json)).toList();
        }

        return PaginatedResult(data: chats, pagination: pagination);
      }
    } catch (e) {
      print("❌ Error fetching chat history: $e");
    }
    return null;
  }

  /// **Send Message (with or without an image)**
  Future<ChatsModel?> sendMessage(
    int roomId,
    String message, {
    File? file,
  }) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) {
        log("⚠️ User token is null. Cannot send message.");
        return null;
      }

      var url = Uri.parse("$baseUrl${ApiRoutes.sendMessageEndpoint}");
      log("📡 Sending POST request to: $url");

      var request =
          http.MultipartRequest("POST", url)
            ..fields['room_id'] = roomId.toString()
            ..fields['message'] = message;

      // ✅ Attach file if available
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      request.headers.addAll({"Authorization": "Bearer $token"});

      var response = await request.send();
      log("📩 API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseData);
        final dynamic rawChat =
            jsonResponse['data'] is Map<String, dynamic>
                ? jsonResponse['data']
                : jsonResponse;

        if (rawChat is Map<String, dynamic>) {
          return ChatsModel.fromJson(rawChat);
        }

        log("❌ Unexpected send message response: $jsonResponse");
        return null;
      } else {
        log("❌ Failed to send message: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while sending message: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchPlotDetails(int plotId) async {
    try {
      print("🔹 Fetching Plot Details for Plot ID: $plotId");

      // **Retrieve Auth Token from Local Storage**
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null || authToken.isEmpty) {
        print("❌ Error: No Auth Token Found");
        return null;
      }

      // **Construct API URL**
      String apiUrl = "$baseUrl${ApiRoutes.plotsEndpoint}$plotId";

      print("🌍 API Request URL: $apiUrl");
      print("🔑 Authorization: Bearer $authToken");

      // **API Request with Authorization Header**
      Response response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $authToken", // ✅ Auth Header
            "Content-Type": "application/json",
          },
          validateStatus: (status) {
            return status! < 500; // ✅ Allow 400 responses for debugging
          },
        ),
      );

      print("✅ API Raw Response: ${response.data}");

      // **Handle API Response**
      if (response.statusCode == 200 && response.data['success'] == true) {
        var plotData = response.data['data'];

        // ✅ **Extract Only Required Fields**
        Map<String, dynamic> extractedPlotDetails = {
          "id": plotData["id"],
          "plot_name": plotData["plot_name"] ?? "N/A",
          "crops_id": plotData["crops_id"] ?? "N/A",
          "variety": plotData["variety"] ?? "N/A",
          "pruning_type": plotData["pruning_type"] ?? "N/A",
          "prunning_date": _formatDate(plotData["prunning_date"]),
          "planting_date": _formatDate(plotData["planting_date"]),
          "cutting_date": _formatDate(plotData["cutting_date"]),
          "area": plotData["area"] ?? "N/A",
          "area_unit": plotData["area_unit"] ?? "N/A",
          "soil_type": plotData["soil_type"] ?? "N/A",
          "location": plotData["location"] ?? "N/A",
          "irrigation_type": plotData["irrigation_type"] ?? "N/A",
          "structure": plotData["structure"] ?? "N/A",
          "soil_ph": plotData["soil_ph"] ?? "N/A",
          "water_resource": plotData["water_resource"] ?? "N/A",
          "createdAt": plotData["createdAt"] ?? "N/A",
        };

        print("✅ Extracted Plot Details: $extractedPlotDetails");
        return extractedPlotDetails;
      } else {
        print(
          "⚠️ API Error: ${response.statusCode}, Message: ${response.data}",
        );
        return null;
      }
    } catch (e) {
      print("❌ Exception Fetching Plot Details: $e");
      return null;
    }
  }

  /// **Format Date Safely**
  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(date.toString());
      return "${parsedDate.year}-${parsedDate.month}-${parsedDate.day}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  /// **Fetch Crops List**
  Future<Map<int, String>?> fetchCrops() async {
    try {
      print("🔹 Fetching Crops List...");

      // **Retrieve Auth Token from Local Storage**
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) {
        print("❌ Error: No Auth Token Found");
        return null;
      }

      // **API Request**
      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.cropsEndpoint}",
        options: Options(
          headers: {
            "Authorization": "Bearer $authToken",
            "Content-Type": "application/json",
          },
        ),
      );

      print("✅ API Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> crops = response.data['data'];

        // ✅ Convert List to Map {crop_id: crop_name}
        Map<int, String> cropMap = {
          for (var crop in crops) crop['id']: crop['name'],
        };

        print("✅ Fetched Crops: $cropMap");
        return cropMap;
      } else {
        print("⚠️ Failed to fetch crops: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error Fetching Crops: $e");
      return null;
    }
  }

  /// **Fetch Pruning Types**
  Future<Map<int, String>?> fetchPruningTypes() async {
    try {
      print("🔹 Fetching Pruning Types...");

      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) {
        print("❌ Error: No Auth Token Found");
        return null;
      }

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.pruningTypesEndpoint}",
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> pruningTypes = response.data['data'];
        Map<int, String> pruningTypeMap = {
          for (var item in pruningTypes) item['id']: item['name'],
        };

        print("✅ Fetched Pruning Types: $pruningTypeMap");
        return pruningTypeMap;
      } else {
        print("⚠️ Failed to fetch pruning types: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error Fetching Pruning Types: $e");
      return null;
    }
  }

  /// **Fetch Plantation Types**
  Future<Map<int, String>?> fetchPlantationTypes() async {
    try {
      print("🔹 Fetching Plantation Types...");

      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) {
        print("❌ Error: No Auth Token Found");
        return null;
      }

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.plantationTypesEndpoint}",
        options: Options(headers: {"Authorization": "Bearer $authToken"}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> plantationTypes = response.data['data'];
        Map<int, String> plantationTypeMap = {
          for (var item in plantationTypes) item['id']: item['name'],
        };

        print("✅ Fetched Plantation Types: $plantationTypeMap");
        return plantationTypeMap;
      } else {
        print("⚠️ Failed to fetch plantation types: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error Fetching Plantation Types: $e");
      return null;
    }
  }

  /// **Fetch Crop Varieties based on Crop ID**
  Future<Map<int, String>?> fetchCropVarieties(int cropId) async {
    try {
      print("🔹 Fetching Varieties for Crop ID: $cropId");

      // **Retrieve Auth Token from Local Storage**
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) {
        print("❌ Error: No Auth Token Found");
        return null;
      }

      // **API Request**
      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.cropVarietiesEndpoint}$cropId",
        options: Options(
          headers: {
            "Authorization": "Bearer $authToken",
            "Content-Type": "application/json",
          },
        ),
      );

      print("✅ API Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> varieties = response.data['data'];

        // ✅ Convert List to Map {variety_id: variety_name}
        Map<int, String> varietyMap = {
          for (var variety in varieties) variety['id']: variety['name'],
        };

        print("✅ Fetched Crop Varieties: $varietyMap");
        return varietyMap;
      } else {
        print("⚠️ Failed to fetch varieties: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error Fetching Crop Varieties: $e");
      return null;
    }
  }
}
