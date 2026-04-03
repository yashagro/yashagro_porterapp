import 'dart:async';
import 'package:get/get.dart';
import 'package:partener_app/expert/chats/model/chat_room_model.dart';
import 'package:partener_app/expert/chats/repo/chat_api_service.dart';

class ChatListController extends GetxController {
  RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  RxList<ChatRoomModel> filteredChatRooms = <ChatRoomModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadMore = false.obs;

  int currentPage = 1;
  bool hasMore = true;
  String currentSearch = "";
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  Future<void> fetchChats({String search = "", bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMore = true;
      currentSearch = search;
      isLoading.value = true;
    }

    try {
      final result = await ChatApiService().fetchChatRooms(
        page: currentPage,
        search: currentSearch,
      );

      List<ChatRoomModel> chats = result.data;

      // Separate unseen and seen
      List<ChatRoomModel> unseenChats =
          chats.where((chat) => (chat.unseenMsgCount ?? 0) > 0).toList();

      List<ChatRoomModel> seenChats =
          chats.where((chat) => (chat.unseenMsgCount ?? 0) == 0).toList();

      // Sort both by latest message time OR room creation time (descending)
      unseenChats.sort((a, b) {
        DateTime aTime = DateTime.tryParse(a.lastMessage?.createdAt ?? a.createdAt ?? '') ??
            DateTime(2000);
        DateTime bTime = DateTime.tryParse(b.lastMessage?.createdAt ?? b.createdAt ?? '') ??
            DateTime(2000);
        return bTime.compareTo(aTime);
      });

      seenChats.sort((a, b) {
        DateTime aTime = DateTime.tryParse(a.lastMessage?.createdAt ?? a.createdAt ?? '') ??
            DateTime(2000);
        DateTime bTime = DateTime.tryParse(b.lastMessage?.createdAt ?? b.createdAt ?? '') ??
            DateTime(2000);
        return bTime.compareTo(aTime);
      });

      List<ChatRoomModel> sortedChats = [...unseenChats, ...seenChats];

      if (isRefresh) {
        chatRooms.assignAll(sortedChats);
      } else {
        chatRooms.addAll(sortedChats);
      }
      filteredChatRooms.assignAll(chatRooms);

      if (result.pagination != null) {
        hasMore = currentPage < result.pagination!.totalPages;
      } else {
        hasMore = false;
      }
    } catch (e) {
      print("❌ Error fetching chat rooms: $e");
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  Future<void> loadMoreChats() async {
    if (isLoading.value || isLoadMore.value || !hasMore) return;

    isLoadMore.value = true;
    currentPage++;
    await fetchChats(isRefresh: false);
  }

  void filterChats(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchChats(search: query);
    });
  }
}
