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
      List<ChatRoomModel> validChats =
          chats.where((chat) => chat.lastMessage != null).toList();

      // Separate unseen and seen
      List<ChatRoomModel> unseenChats =
          validChats.where((chat) => (chat.unseenMsgCount ?? 0) > 0).toList();

      List<ChatRoomModel> seenChats =
          validChats.where((chat) => (chat.unseenMsgCount ?? 0) == 0).toList();

      // Sort both by latest message time (descending)
      unseenChats.sort((a, b) {
        DateTime aTime =
            DateTime.tryParse(a.lastMessage?.createdAt ?? '') ?? DateTime(2000);
        DateTime bTime =
            DateTime.tryParse(b.lastMessage?.createdAt ?? '') ?? DateTime(2000);
        return bTime.compareTo(aTime); // latest first
      });

      seenChats.sort((a, b) {
        DateTime aTime =
            DateTime.tryParse(a.lastMessage?.createdAt ?? '') ?? DateTime(2000);
        DateTime bTime =
            DateTime.tryParse(b.lastMessage?.createdAt ?? '') ?? DateTime(2000);
        return bTime.compareTo(aTime); // latest first
      });

      chatRooms.value = [...unseenChats, ...seenChats];
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
