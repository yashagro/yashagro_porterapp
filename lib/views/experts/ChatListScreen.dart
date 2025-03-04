import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:partener_app/services/api_service.dart';
import 'package:partener_app/views/experts/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> chatRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  /// **Fetch All Chat Rooms**
  Future<void> _fetchChats() async {
    try {
      var chats = await _apiService.fetchChatRooms();
      if (chats != null) {
        setState(() {
          chatRooms =
              chats
                  .where((chat) => chat["last_message"] != null)
                  .toList(); // ✅ Show only chats with last messages
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching chat rooms: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),

      /// **Chat List**
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // ✅ Loading Indicator
              : chatRooms.isEmpty
              ? Center(child: Text("No Chats Available")) // ✅ No Chats
              : ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  var chat = chatRooms[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          chat["user"]["image"] != null
                              ? NetworkImage(chat["user"]["image"])
                              : AssetImage("assets/default_user.png")
                                  as ImageProvider,
                    ),
                    title: Text(chat["user"]["name"] ?? "Unknown"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chat["user"]["mobile_no"] ?? "No Mobile"),
                        Text(
                          "Plot: ${chat["plot"]["name"] ?? "N/A"}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    trailing:
                        chat["last_message"] != null
                            ? Text(
                              _formatTime(chat["last_message"]["createdAt"]),
                            )
                            : Text("No messages"),
                    onTap: () async {
                      int roomId = chat["id"];

                      // ✅ Check if room exists, if not, start a new chat
                      if (roomId == null) {
                        roomId =
                            await _apiService.startChat(chat["plot"]["id"]) ??
                            0;
                      }

                      if (roomId > 0) {
                        Get.to(() => ChatScreen(roomId: roomId));
                      } else {
                        Get.snackbar("Error", "Failed to start chat");
                      }
                    },
                  );
                },
              ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "";
    DateTime time = DateTime.parse(timestamp);
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}
