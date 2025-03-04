import 'dart:developer';
import 'package:get/get.dart';
import 'package:partener_app/services/api_service.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/models/chats_model.dart';

class ChatsController extends GetxController {
  RxList<ChatsModel> chatsList = <ChatsModel>[].obs;
  RxBool isLoading = false.obs;
  String authToken = '';

  @override
  void onInit() {
    getToken();
    super.onInit();
  }

  /// **🔹 Fetch JWT Token**
  void getToken() async {
    authToken = await SharedPrefs.getUserToken() ?? '';
    log("🔑 Auth Token: $authToken");
  }

  /// **🔹 Set Chats List**
  void setChats(List<ChatsModel> chats) {
    chatsList.value = chats;
  }

  

  
  /// **Fetch & Set Chat History**
  Future<void> loadChatHistory(int roomId) async {
    isLoading.value = true;
    List<ChatsModel>? chats = await ApiService().fetchChatHistory(roomId);
    if (chats != null) {
      chatsList.value = chats;
    }
    isLoading.value = false;
  }

  /// **Insert a New Message**
  void insertChat(ChatsModel chat) {
    chatsList.insert(0, chat); // ✅ Add message to chat list
  }

  /// **Clear Chat History**
  void clearChats() {
    chatsList.clear();
  }
}
