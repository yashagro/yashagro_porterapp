import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/expert/chats/controller/chats_controller.dart';
import 'package:partener_app/expert/chats/controller/web_socket_controller.dart';
import 'package:partener_app/expert/chats/repo/chat_api_service.dart';
import 'package:partener_app/models/chats_model.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/expert/chats/model/chat_room_model.dart';
import 'package:partener_app/expert/farmer_details/view/farmer_details_screen.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int roomId;

  const ChatScreen({super.key, required this.roomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatsController chatController = Get.put(ChatsController());
  final WebSocketController socketController = Get.find<WebSocketController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatRoomModel? chatRoom;

  int userId = 0;
  File? selectedImage;
  // Map<String, dynamic> userData = {};
  @override
  void initState() {
    super.initState();
    _initializeChat();
    _fetchChatRoomDetails();
  }

  @override
  void dispose() {
    socketController.leaveChat(widget.roomId.toString());
    chatController.chatsList.clear();
    super.dispose();
    // ExpertApiService().makeUnseenCountZeor(widget.roomId);
  }

  Future<void> _initializeChat() async {
    userId = await SharedPrefs.getUserId() ?? 0;
    await chatController.loadChatHistory(widget.roomId);
    _scrollToBottom();
    socketController.joinChat(widget.roomId.toString());

    await _fetchChatRoomDetails();
  }

  /// **🔹 Fetch User Details from Chat Room**
  Future<void> _fetchChatRoomDetails() async {
    List<ChatRoomModel> rooms = await ChatApiService().fetchChatRooms();

    if (rooms.isNotEmpty) {
      chatRoom = rooms.firstWhere(
        (room) => room.id == widget.roomId,
        orElse: () => ChatRoomModel(), // fallback to empty model
      );
      setState(() {}); // ✅ Trigger rebuild for AppBar
    } else {
      print("⚠️ No chat rooms found for this user.");
    }
  }

  /// **Pick an Image from Gallery**
  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedImage = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF9F6),

      /// **🔹 AppBar with User Details Button**
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Color(0xFFFAF9F6),
          centerTitle: false,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatRoom?.user?.name ?? "User",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (chatRoom?.plot?.name != null)
                Text(
                  chatRoom!.plot!.name!,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.person_outline, size: 28, color: Colors.black),
              tooltip: "View User Details",
              onPressed: () {
                if (chatRoom?.user != null) {
                  Get.to(() => UserDetailsScreen(chatRoom: chatRoom!));
                } else {
                  Get.snackbar("Error", "User details not available.");
                }
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );

              if (chatController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (chatController.chatsList.isEmpty) {
                return Center(child: Text("No messages yet"));
              }
              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: chatController.chatsList.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(chatController.chatsList[index]);
                },
              );
            }),
          ),
          if (selectedImage != null)
            _buildImagePreview(), // Image preview before sending
          _buildMessageInput(),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController
            .position
            .minScrollExtent, // reverse:true, so minScrollExtent
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// **Build Chat Bubble with Image and Text**
  Widget _buildChatBubble(ChatsModel chat) {
    bool isSentByMe = chat.sender?.roleId == 3;

    bool isImageMessage = chat.file != null && chat.file!.isNotEmpty;
    bool isTextMessage = chat.message != null && chat.message!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Align(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSentByMe ? Color(0xFFdcf8c6) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft:
                      isSentByMe ? Radius.circular(12) : Radius.circular(0),
                  bottomRight:
                      isSentByMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isImageMessage) _buildSingleImage(chat.file!),
                  if (isTextMessage)
                    Padding(
                      padding: EdgeInsets.only(top: isImageMessage ? 8 : 0),
                      child: Text(
                        chat.message!,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),

            /// 🕒 Time
            Padding(
              padding: EdgeInsets.only(top: 3, left: 5, right: 5),
              child: Text(
                _formatTime(chat.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),

            /// 👤 Sender Name if role_id == 3
            if (chat.sender?.roleId == 3)
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  (chat.sender?.senderId == userId)
                      ? "Me"
                      : (chat.sender?.name ?? ""),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// **Single Image Widget**
  Widget _buildSingleImage(String imageUrl) {
    String secureUrl = imageUrl.replaceFirst("http://", "https://");

    return GestureDetector(
      onTap: () {
        // ✅ Corrected here
        List<String> allImages =
            chatController.chatsList
                .where((chat) => chat.file != null && chat.file!.isNotEmpty)
                .map((chat) => chat.file!.replaceFirst("http://", "https://"))
                .toList()
                .cast<String>(); // ✅ Add .cast<String>()

        int initialIndex = allImages.indexOf(secureUrl);

        Get.to(
          () => FullScreenImageGallery(
            images: allImages,
            initialIndex: initialIndex,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          secureUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// **Image Preview Before Sending**
  Widget _buildImagePreview() {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              selectedImage!,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  setState(() {
                    selectedImage = null;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.green),
                onPressed: () => _sendMessageWithImage(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// **Message Input Field**
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          // 📸 Image Picker Button inside rounded box
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.photo, color: Colors.blueAccent),
              onPressed: pickImage,
            ),
          ),
          SizedBox(width: 8),

          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 40, maxHeight: 150),
                child: Scrollbar(
                  child: TextField(
                    controller: messageController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessageWithImage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessageWithImage() async {
    String message = messageController.text.trim();

    if (message.isEmpty && selectedImage == null) {
      Get.snackbar("Error", "Message cannot be empty");
      return;
    }

    // ✅ Convert file path to File object (if available)
    File? imageFile = selectedImage != null ? File(selectedImage!.path) : null;

    await chatController.sendMessage(widget.roomId, message, file: imageFile);
    _scrollToBottom(); // <- Scroll after sending

    setState(() {
      selectedImage = null;
      messageController.clear();
    });
  }
}

String _formatTime(String? timestamp) {
  if (timestamp == null || timestamp.isEmpty) return "No time";

  try {
    DateTime utcTime = DateTime.parse(timestamp).toUtc();
    DateTime istTime = utcTime.add(Duration(hours: 5, minutes: 30));
    DateTime now = DateTime.now();
    Duration diff = now.difference(istTime);

    if (diff.inMinutes <= 1) {
      return "1 min ago";
    } else if (diff.inMinutes <= 2) {
      return "2 min ago";
    } else if (diff.inMinutes <= 3) {
      return "3 min ago";
    } else if (diff.inMinutes <= 5) {
      return "5 min ago";
    } else if (diff.inMinutes <= 10) {
      return "10 min ago";
    } else if (diff.inMinutes <= 30) {
      return "Half hour ago";
    } else if (now.difference(istTime).inDays == 1) {
      return "Yesterday";
    } else {
      String dayDate = DateFormat('E d MMM').format(istTime);
      String time = DateFormat('h:mm a').format(istTime);
      return "$dayDate, $time";
    }
  } catch (e) {
    print("❌ Error formatting time: $e");
    return "Invalid time";
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Preview")),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int currentIndex;
  double _rotationAngle = 0.0; // ⬅️ New: Track rotation

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _rotateImage() {
    setState(() {
      _rotationAngle += 90;
      if (_rotationAngle == 360) _rotationAngle = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            reverse: true,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
                _rotationAngle = 0; // Reset rotation on new image
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Transform.rotate(
                    angle: _rotationAngle * 3.1415926535 / 180,
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain, // ✅ Not 'fill'
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              );
            },
          ),

          // 🔙 Close Button
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // 🔢 Image Counter
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              '${currentIndex + 1}/${widget.images.length}',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),

          // 🔄 Rotate Button (Optional but professional!)
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black45,
              onPressed: _rotateImage,
              child: Icon(Icons.rotate_right, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
