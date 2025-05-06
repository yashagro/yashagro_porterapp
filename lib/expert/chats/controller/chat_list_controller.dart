import 'package:get/get.dart';
import 'package:partener_app/expert/chats/model/chat_room_model.dart';
import 'package:partener_app/expert/chats/repo/chat_api_service.dart';

class ChatListController extends GetxController {
  RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  RxList<ChatRoomModel> filteredChatRooms = <ChatRoomModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChats(); // ✅ CALL fetchChats() when Controller Initializes
  }

  Future<void> fetchChats() async {
    try {
      isLoading.value = true;
      List<ChatRoomModel> chats = await ChatApiService().fetchChatRooms();
      chatRooms.value =
          chats.where((chat) => chat.lastMessage != null).toList();
      filteredChatRooms.value = chatRooms;
    } catch (e) {
      print("❌ Error fetching chat rooms: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterChats(String query) {
    if (query.isEmpty) {
      filteredChatRooms.value = chatRooms;
    } else {
      filteredChatRooms.value =
          chatRooms.where((chat) {
            final name = chat.user?.name?.toLowerCase() ?? "";
            return name.contains(query.toLowerCase());
          }).toList();
    }
  }
}
