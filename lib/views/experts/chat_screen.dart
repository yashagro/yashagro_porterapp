import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/controllets/chats_controller.dart';
import 'package:partener_app/controllets/web_socket_controller.dart';
import 'package:partener_app/models/chats_model.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int roomId;
  ChatScreen({required this.roomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatsController chatController = Get.find<ChatsController>();
  final WebSocketController socketController = Get.find<WebSocketController>();
  final ApiService apiService = ApiService();
  final TextEditingController messageController = TextEditingController();
  int? userId; // ✅ Logged-in User ID

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  /// **Initialize Chat: Fetch User ID & Load Chat History**
  Future<void> _initializeChat() async {
    userId = await SharedPrefs.getUserId(); // ✅ Get Stored User ID
    chatController.loadChatHistory(widget.roomId); // ✅ Fetch Chat History
    socketController.joinChat(widget.roomId.toString()); // ✅ Join Chat Room
  }

  @override
  void dispose() {
    socketController.leaveChat(widget.roomId.toString()); // ✅ Leave Chat Room
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Room ${widget.roomId}")),
      body: Column(
        children: [
          /// **Chat Messages List**
          Expanded(
            child: Obx(() {
              if (chatController.isLoading.value) {
                return Center(child: CircularProgressIndicator()); // ✅ Loading
              }

              if (chatController.chatsList.isEmpty) {
                return Center(child: Text("No messages yet")); // ✅ No Messages
              }

              return ListView.builder(
                reverse: true, // ✅ Show latest messages first
                itemCount: chatController.chatsList.length,
                itemBuilder: (context, index) {
                  ChatsModel chat = chatController.chatsList[index];

                  return _buildChatBubble(chat);
                },
              );
            }),
          ),

          /// **Message Input Field**
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// **Build Individual Chat Bubble**
  Widget _buildChatBubble(ChatsModel chat) {
    bool isSentByMe = chat.senderId == userId; // ✅ Compare Sender ID

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blue[100] : Colors.green[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Message Text**
            if (chat.message != null && chat.message!.isNotEmpty)
              Text(chat.message!, style: TextStyle(fontSize: 16)),

            /// **Image Preview (If Available)**
            if (chat.file != null) _buildImagePreview(chat.file!),

            SizedBox(height: 5),
            Text(
              _formatTime(chat.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// **Build Image Preview**
  Widget _buildImagePreview(String imageUrl) {
    return GestureDetector(
      onTap: () {
        Get.to(() => FullScreenImage(imageUrl)); // ✅ Open Image in Full Screen
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Image.network(
          imageUrl,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// **Build Message Input Field**
  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  /// **Send Message via API**
  Future<void> _sendMessage() async {
    String message = messageController.text.trim();
    if (message.isEmpty) return;

    // ✅ Send Message via API
    await apiService.sendMessage(widget.roomId, message);

    // ✅ Do NOT insert message manually (WebSocket will handle it)
    messageController.clear();
  }

  /// **Format Timestamp**
  String _formatTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "";
    DateTime time = DateTime.parse(timestamp);
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}

/// **Full-Screen Image Viewer**
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  FullScreenImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Preview")),
      body: Center(child: Image.network(imageUrl, fit: BoxFit.contain)),
    );
  }
}
