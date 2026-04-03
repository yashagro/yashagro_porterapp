import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:partener_app/services/api_service.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/models/chats_model.dart';

class ChatsController extends GetxController {
  RxList<ChatsModel> chatsList = <ChatsModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadMoreHistory = false.obs;
  String authToken = '';
  int? userId;

  int currentPage = 1;
  bool hasMore = true;

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
    chatsList.assignAll(chats);
  }

  /// **🔹 Fetch & Set Chat History (Paginated)**
  Future<void> loadChatHistory(int roomId, {bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMore = true;
      isLoading.value = true;
    }

    try {
      final result =
          await ApiService().fetchChatHistory(roomId, page: currentPage);
      if (result != null) {
        if (isRefresh) {
          chatsList.assignAll(result.data);
        } else {
          chatsList.addAll(result.data);
        }

        if (result.pagination != null) {
          hasMore = currentPage < result.pagination!.totalPages;
        } else {
          hasMore = false;
        }
        log("📥 Loaded ${result.data.length} messages for Room ID: $roomId (Page: $currentPage)");
      } else {
        log("⚠️ No chat history found for Room ID: $roomId");
      }
    } catch (e) {
      log("❌ Error loading chat history: $e");
    } finally {
      isLoading.value = false;
      isLoadMoreHistory.value = false;
    }
  }

  /// **🔹 Load More Chat History**
  Future<void> loadMoreHistory(int roomId) async {
    if (isLoading.value || isLoadMoreHistory.value || !hasMore) return;

    isLoadMoreHistory.value = true;
    currentPage++;
    await loadChatHistory(roomId, isRefresh: false);
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
