import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:partener_app/expert/chats/model/chat_room_model.dart';
import 'package:partener_app/expert/chats/view/chat_screen.dart';
import 'package:partener_app/expert/chats/controller/chat_list_controller.dart';

class ChatListScreen extends StatefulWidget {
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
 late final ChatListController controller;

  @override
  void initState() {
    super.initState();

    // ✅ Create controller only once
    controller = Get.put(ChatListController(), permanent: true);

    // ✅ Fetch chats ONLY ONCE
    controller.fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF9F6),
      appBar: AppBar(
        title: Text("Chats", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(0xFFFAF9F6),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: controller.filterChats,
              decoration: InputDecoration(
                hintText: "Search",
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (controller.filteredChatRooms.isEmpty) {
                return Center(child: Text("No Chats Found"));
              }
              return RefreshIndicator(
                // ✅ Add this
                onRefresh: () async {
                  await controller.fetchChats(); // ✅ Re-fetch chats
                },
                child: ListView.builder(
                  itemCount: controller.filteredChatRooms.length,
                  itemBuilder: (context, index) {
                    var chat = controller.filteredChatRooms[index];
                    return _buildChatItem(chat);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatRoomModel chat) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage:
                (chat.user != null && chat.user?.image != null)
                    ? NetworkImage(chat.user?.image ?? '')
                    : AssetImage("assets/default_profile.png") as ImageProvider,
          ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: chat.user?.name ?? "Unknown",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                if (chat.plot?.name != null)
                  TextSpan(
                    text: " (${chat.plot?.name})",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            chat.lastMessage?.message ?? "No messages yet",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(chat.lastMessage?.createdAt ?? ''),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if ((chat.unseenMsgCount ?? 0) > 0)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${chat.unseenMsgCount}",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () async {
            int roomId = chat.id ?? 0;
            if (roomId > 0) {
              await Get.to(() => ChatScreen(roomId: roomId));
              Future.delayed(Duration(seconds: 1), () {
                controller.fetchChats(); // ✅ Refresh chats after returning
              });
            } else {
              Get.snackbar("Error", "Failed to start chat");
            }
          },
        ),
        Divider(),
      ],
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "No time";
    try {
      DateTime utcTime = DateTime.parse(timestamp).toUtc();
      DateTime istTime = utcTime.add(Duration(hours: 5, minutes: 30));
      DateTime now = DateTime.now();
      Duration diff = now.difference(istTime);

      if (diff.inMinutes <= 1) return "1 min ago";
      if (diff.inMinutes <= 2) return "2 min ago";
      if (diff.inMinutes <= 3) return "3 min ago";
      if (diff.inMinutes <= 5) return "5 min ago";
      if (diff.inMinutes <= 10) return "10 min ago";
      if (diff.inMinutes <= 30) return "Half hour ago";
      if (now.day == istTime.day) return DateFormat('h:mm a').format(istTime);
      if (now.difference(istTime).inDays == 1) return "Yesterday";
      if (now.difference(istTime).inDays <= 6)
        return DateFormat('EEEE').format(istTime);
      return DateFormat('dd MMM').format(istTime);
    } catch (e) {
      print("❌ Error formatting time: $e");
      return "Invalid time";
    }
  }
}
