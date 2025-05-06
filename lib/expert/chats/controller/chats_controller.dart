import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:partener_app/services/api_service.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/models/chats_model.dart';

class ChatsController extends GetxController {
  RxList<ChatsModel> chatsList = <ChatsModel>[].obs;
  RxBool isLoading = false.obs;
  String authToken = '';
  int? userId; // ✅ Store Logged-in User ID

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  /// **🔹 Fetch JWT Token & User ID**
  Future<void> _initializeAuth() async {
    try {
      authToken = await SharedPrefs.getUserToken() ?? '';
      userId = await SharedPrefs.getUserId();
      log("🔑 Auth Token: $authToken, User ID: $userId");
    } catch (e) {
      log("❌ Error fetching auth token or user ID: $e");
    }
  }

  /// **🔹 Set Chats List**
  void setChats(List<ChatsModel> chats) {
    chatsList.assignAll(chats); // ✅ Efficient list update
  }

  /// **🔹 Fetch & Set Chat History (Improved)**
  Future<void> loadChatHistory(int roomId) async {
    isLoading.value = true;
    try {
      List<ChatsModel>? chats = await ApiService().fetchChatHistory(roomId);
      if (chats != null && chats.isNotEmpty) {
        chatsList.assignAll(chats); // ✅ Prevent unnecessary overwrites
        log("📥 Loaded ${chats.length} messages for Room ID: $roomId");
      } else {
        log("⚠️ No chat history found for Room ID: $roomId");
      }
    } catch (e) {
      log("❌ Error loading chat history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// **🔹 Insert New Chat Message Safely**
  void insertChat(ChatsModel chat) {
    if (!chatsList.any((item) => item.id == chat.id) && chat.id != 0) {
      chatsList.insert(0, chat); // ✅ Adds message to the top
      update(); // ✅ Refresh UI
      log("📩 New message inserted: ${chat.message}");
    } else {
      log("⚠️ Duplicate message, skipping insertion");
    }
  }

  /// **🔹 Clear Chat History**
  void clearChats() {
    chatsList.clear();
    log("🗑️ Chat history cleared.");
  }

  /// **📤 Send Message (Text & Image Support)**
  Future<ChatsModel?> sendMessage(
    int roomId,
    String message, {
    File? file,
  }) async {
    log("📤 Sending message: '$message' to Room ID: $roomId");

    try {
      ChatsModel? sentMessage = await ApiService().sendMessage(
        roomId,
        message,
        file: file,
      );

      if (sentMessage != null) {
        log("✅ Message sent successfully: ${sentMessage.message}");
        return sentMessage;
      } else {
        log("❌ Failed to send message");
        return null;
      }
    } catch (e) {
      log("❌ Error sending message: $e");
      return null;
    }
  }
}
