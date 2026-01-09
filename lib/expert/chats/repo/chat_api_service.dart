import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:partener_app/constants.dart';
import 'package:partener_app/models/chats_model.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/expert/chats/model/chat_room_model.dart';

class ChatApiService {
  final Dio _dio = Dio();
  final String baseUrl = ApiRoutes.baseUri;

  /// Fetch Expert Chat Rooms
  Future<List<ChatRoomModel>> fetchChatRooms() async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) return [];

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.chatRoomsEndpoint}",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return (response.data['data'] as List)
            .map((json) => ChatRoomModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching chat rooms: $e");
    }
    return [];
  }

  /// Fetch Chat History
  Future<List<ChatsModel>?> fetchChatHistory(int roomId) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.chatHistoryEndpoint}$roomId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return (response.data["data"] as List)
            .map((json) => ChatsModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching chat history: $e");
    }
    return null;
  }

  /// Start Chat
  Future<int?> startChat(int plotId) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) return null;

      Response response = await _dio.post(
        "$baseUrl${ApiRoutes.startChatEndpoint}",
        data: {"plot_id": plotId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return response.data["data"]["id"];
      } else {
        print("⚠️ Chat start failed: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error starting chat: $e");
      return null;
    }
  }

  /// Send Message (with or without image)
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

      var request = http.MultipartRequest("POST", url)
        ..fields['room_id'] = roomId.toString()
        ..fields['message'] = message;

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      request.headers.addAll({"Authorization": "Bearer $token"});

      var response = await request.send();
      log("📩 API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseData);
        return ChatsModel.fromJson(jsonResponse);
      } else {
        log("❌ Failed to send message: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("❌ Exception while sending message: $e");
      return null;
    }
  }

  /// Mark Chat as Seen
  Future<void> makeUnseenCountZeor(int roomId) async {
    try {
      String? authToken = await SharedPrefs.getUserToken();
      if (authToken == null) {
        print("❌ Error: No Auth Token Found");
        return;
      }

      Response response = await _dio.put(
        "$baseUrl/api/chats/update-is-seen",
        data: {"room_id": roomId},
        options: Options(
          headers: {
            "Authorization": "Bearer $authToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("✅ Unseen count reset for room ID $roomId");
      }
    } catch (e) {
      print("❌ Error resetting unseen count: $e");
    }
  }
}
