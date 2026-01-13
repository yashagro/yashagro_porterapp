import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:partener_app/expert/chats/view/audio_chat_bubble.dart';
import 'package:partener_app/expert/chats/view/blur_loader.dart';
import 'package:record/record.dart';

import 'package:partener_app/expert/chats/controller/chats_controller.dart';
import 'package:partener_app/expert/chats/controller/web_socket_controller.dart';
import 'package:partener_app/expert/chats/repo/chat_api_service.dart';
import 'package:partener_app/models/chats_model.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/expert/chats/model/chat_room_model.dart';
import 'package:partener_app/expert/farmer_details/view/farmer_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final int roomId;

  const ChatScreen({super.key, required this.roomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  
// RIGHT — use the instance registered in your bindings
final ChatsController chatController = Get.find<ChatsController>();

  final WebSocketController socketController = Get.find<WebSocketController>();

  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _rec = AudioRecorder();
 final AudioPlayer _audioPlayer = AudioPlayer();
String? _playingUrl;
Duration _audioPosition = Duration.zero;
Duration _audioDuration = Duration.zero;

  ChatRoomModel? chatRoom;
  int userId = 0;

  // attachment state
  File? _selectedFile;          // image | video | audio
  String _selectedType = '';    // 'image' | 'video' | 'audio'
final RxBool _isSending = false.obs;
  // audio record state
  bool _isRecording = false;
  String? _pendingAudioPath;
  Timer? _recTimer;
  int _elapsed = 0;
  int _lastRecordedSecs = 0;
double _amp = 0.0;                       // 0..1 normalized
StreamSubscription<Amplitude>? _ampSub;  // from `record`
Timer? _ampPoll;                         // fallback polling

  @override
  void initState() {
    super.initState();
      _audioPlayer.onPositionChanged.listen((p) {
    setState(() => _audioPosition = p);
  });

  _audioPlayer.onDurationChanged.listen((d) {
    setState(() => _audioDuration = d);
  });

  _audioPlayer.onPlayerComplete.listen((event) {
    setState(() {
      _playingUrl = null;
      _audioPosition = Duration.zero;
    });
  });
    _initializeChat();
    _fetchChatRoomDetails();
  }

  @override
  void dispose() {
     _audioPlayer.dispose();
    socketController.leaveChat(widget.roomId.toString());
    chatController.chatsList.clear();
    _recTimer?.cancel();
    
    _recTimer = null;
    if (_isRecording) {
      _rec.stop();
    }
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
void _startAmp() async {
  try {
    _ampSub = _rec
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen((a) {
      final db = a.current; // ~ -45..0
      setState(() => _amp = ((db + 45) / 45).clamp(0.0, 1.0));
    });
  } catch (_) {
    _ampPoll?.cancel();
    _ampPoll = Timer.periodic(const Duration(milliseconds: 120), (_) async {
      try {
        final a = await _rec.getAmplitude();
        final db = a.current;
        setState(() => _amp = ((db + 45) / 45).clamp(0.0, 1.0));
      } catch (_) {}
    });
  }
}

Future<void> _stopAmp() async {
  await _ampSub?.cancel();
  _ampSub = null;
  _ampPoll?.cancel();
  _ampPoll = null;
  if (mounted) setState(() => _amp = 0.0);
}

  Future<void> _initializeChat() async {
    userId = await SharedPrefs.getUserId() ?? 0;
    await chatController.loadChatHistory(widget.roomId);
    _jumpToBottom();
    socketController.joinChat(widget.roomId.toString());
  }

  Future<void> _fetchChatRoomDetails() async {
    final rooms = await ChatApiService().fetchChatRooms();
    if (!mounted) return;
    if (rooms.isNotEmpty) {
      setState(() {
        chatRoom = rooms.firstWhere(
          (r) => r.id == widget.roomId,
          orElse: () => ChatRoomModel(),
        );
      });
    }
  }

  // ───────────────────────── UI helpers ─────────────────────────
  void _jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent, // reverse:true
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _mmss(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  // ─────────────────────── Attachment dialog ───────────────────────
  Future<void> _openAttachPicker() async {
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 52, vertical: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Attachment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Pick(icon: Icons.photo_camera_rounded, label: 'Camera', onTap: () => Navigator.pop(ctx, 'camera_image')),
                  _Pick(icon: Icons.image_rounded, label: 'Gallery', onTap: () => Navigator.pop(ctx, 'gallery_image')),
                  _Pick(icon: Icons.videocam_rounded, label: 'Video', onTap: () => Navigator.pop(ctx, 'video')),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );

    switch (action) {
      case 'camera_image':
        await _pickImage(ImageSource.camera);
        break;
      case 'gallery_image':
        await _pickImage(ImageSource.gallery);
        break;
      case 'video':
        await _pickVideo();
        break;
    }
  }

  // ─────────────────────────── Pickers ───────────────────────────
  Future<void> _pickImage(ImageSource src) async {
    final x = await _picker.pickImage(source: src, imageQuality: 85, maxWidth: 2048);
    if (x == null) return;
    setState(() {
      _selectedFile = File(x.path);
      _selectedType = 'image';
    });
  }

  Future<void> _pickVideo() async {
    final src = await showDialog<ImageSource>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Video', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Pick(icon: Icons.videocam_rounded, label: 'Camera', onTap: () => Navigator.pop(ctx, ImageSource.camera)),
                  _Pick(icon: Icons.video_library_rounded, label: 'Gallery', onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
    if (src == null) return;

    final x = await _picker.pickVideo(source: src, maxDuration: const Duration(minutes: 2));
    if (x == null) return;
    setState(() {
      _selectedFile = File(x.path);
      _selectedType = 'video';
    });
  }

  // ─────────────────────── Audio record/mic flow ───────────────────────
Future<void> _toggleRecord() async {
  if (!_isRecording) {
    if (await _rec.hasPermission()) {
      final path = '${Directory.systemTemp.path}/vn_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _rec.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: path,
      );
      _pendingAudioPath = path;
      _elapsed = 0;
      _recTimer?.cancel();
      _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed++);
      });

      _startAmp();                    // 👈 start amplitude
      setState(() => _isRecording = true);
    } else {
      Get.snackbar('Permission', 'Microphone permission is required');
    }
  } else {
    final stopPath = await _rec.stop();
    _recTimer?.cancel();
    _recTimer = null;
    await _stopAmp();                 // 👈 stop amplitude

    _lastRecordedSecs = _elapsed;
    final path = stopPath ?? _pendingAudioPath;
    _pendingAudioPath = path;

    if (path != null) {
      setState(() {
        _selectedFile = File(path);
        _selectedType = 'audio';
      });
    }
    setState(() => _isRecording = false);
  }
}


  void _clearPendingMedia() {
    setState(() {
      _selectedFile = null;
      _selectedType = '';
    });
  }

  // ─────────────────────────── Sender ───────────────────────────
  Future<void> _sendMessage() async {
    final msg = messageController.text.trim();

    if (msg.isEmpty && _selectedFile == null) {
      Get.snackbar("Error", "Message cannot be empty");
      return;
    }
 _isSending.value = true; 
 
    try {
    await chatController.sendMessage(
      widget.roomId,
      msg,
      file: _selectedFile,
    );

    setState(() {
      _selectedFile = null;
      _selectedType = '';
      messageController.clear();
    });
    _jumpToBottom();
  } finally {
    _isSending.value = false; // 👈 stop overlay
  }
  }
    Color waGreen = Color(0xFF25D366);
 Color waBubbleMe = Color(0xFFDCF8C6);
 Color waBubbleOther = Color(0xFFFFFFFF);
 Color waBg = Color(0xFFECE5DD);
 Color waGreyText = Color(0xFF667781);
  // ─────────────────────────── Build ───────────────────────────
  @override
  Widget build(BuildContext context) {
 

    return Scaffold(
      backgroundColor: waBg,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFFFAF9F6),
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatRoom?.user?.name ?? "User",
                style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (chatRoom?.plot?.name != null)
                Text(
                  chatRoom!.plot!.name!,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline, size: 28, color: Colors.black),
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
body: Stack(
  children: [
    Column(
      children: [
        Expanded(
          child: Obx(() {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _jumpToBottom());

            if (chatController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (chatController.chatsList.isEmpty) {
              return const Center(child: Text("No messages yet"));
            }

            return ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: chatController.chatsList.length,
              itemBuilder: (context, index) =>
                  _buildChatBubble(chatController.chatsList[index]),
            );
          }),
        ),

        if (_selectedFile != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _selectedType == 'audio'
                ? _audioPreviewChip()
                : _mediaPreviewChip(),
          ),

        _buildMessageInput(),
        const SizedBox(height: 20),
      ],
    ),

    /// ✅ LOADER OVERLAY (CORRECT)
    Obx(() => _isSending.value
        ? Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: BlurDotsLoader()),
              ),
            ),
          )
        : const SizedBox.shrink()),
  ],
),

    );
  }

String _formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "$m:$s";
}

  // ─────────────────────── Chat bubble content ───────────────────────
  Widget _buildChatBubble(ChatsModel chat) {
    print(chat.file);
    final isSentByMe = chat.sender?.roleId == 3;
   final file = chat.file?.toLowerCase() ?? '';

final isImageMessage = file.endsWith('.jpg') ||
    file.endsWith('.jpeg') ||
    file.endsWith('.png') ||
    file.endsWith('.webp') ||
    file.endsWith('.gif');

final isVideoMessage = file.endsWith('.mp4') ||
    file.endsWith('.mov') ||
    file.endsWith('.mkv');

final isAudioMessage = file.endsWith('.m4a') ||
    file.endsWith('.aac') ||
    file.endsWith('.mp3') ||
    file.endsWith('.wav');

final isTextMessage = (chat.message ?? '').isNotEmpty;


    return Padding(
      
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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
              padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
  color: isSentByMe ? waBubbleMe : waBubbleOther,
  borderRadius: BorderRadius.only(
    topLeft: const Radius.circular(18),
    topRight: const Radius.circular(18),
    bottomLeft: isSentByMe
        ? const Radius.circular(18)
        : const Radius.circular(4),
    bottomRight: isSentByMe
        ? const Radius.circular(4)
        : const Radius.circular(18),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ],
),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isImageMessage) _buildSingleImage(chat.file!),
                  if (isVideoMessage) _buildVideoTile(chat.file!),
                    if (isAudioMessage) AudioMessageBubble(
  audioPath: chat.file!,
  resolveFileUrl: resolveFileUrl,
  waGreen: waGreen,
  waGreyText: waGreyText,
)
,

                  if (isTextMessage)
                    Padding(
                      padding: EdgeInsets.only(top: (isImageMessage || isVideoMessage) ? 8 : 0),
                      child: Text(
                        chat.message!,
                       style: const TextStyle(
  fontSize: 16,
  color: Colors.black87,
  height: 1.25,
),

                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 3, left: 5, right: 5),
              child: Text(
                _formatTime(chat.createdAt),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),

            if (chat.sender?.roleId == 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  (chat.sender?.senderId == userId) ? "Me" : (chat.sender?.name ?? ""),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
   String fileBaseUrl = "https://dev-api.yashagroapp.in";

String resolveFileUrl(String path) {
  if (path.startsWith('http')) return path;
  return "$fileBaseUrl$path";
}

  Widget _buildSingleImage(String imagePath) {
  final url = resolveFileUrl(imagePath);

  return GestureDetector(
    onTap: () {
      final allImages = chatController.chatsList
          .where((c) => (c.file ?? '').isNotEmpty)
          .map((c) => resolveFileUrl(c.file!))
          .toList();

      final initialIndex = allImages.indexOf(url);
      Get.to(() => FullScreenImageGallery(
            images: allImages,
            initialIndex: initialIndex < 0 ? 0 : initialIndex,
          ));
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    ),
  );
}


Widget _buildVideoTile(String videoPath) {
  final url = resolveFileUrl(videoPath);

  return GestureDetector(
    onTap: () async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    },
    child: Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: const Center(
        child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
      ),
    ),
  );
}

  // ─────────────────────── Message input row ───────────────────────
  Widget _buildMessageInput() {
    final hasText = messageController.text.trim().isNotEmpty;
    final hasAttachment = _selectedFile != null;
    final canSend = !_isRecording && (hasText || hasAttachment);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ⬅️ Attach (kept same round look)
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.photo, color: Colors.blueAccent),
              onPressed: _openAttachPicker,
              tooltip: 'Attach',
            ),
          ),
          const SizedBox(width: 8),

          // center rounded text area
         // center rounded text area
Expanded(
  child: _isRecording
      ? _recordingChip()                          // 👈 show chip while recording
      : Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          decoration: BoxDecoration(
        color: waBg,

            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 30, maxHeight: 100),
            child: Scrollbar(
              child: TextField(
                controller: messageController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: "Type your message...",
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
                onTap: _jumpToBottom,
              ),
            ),
          ),
        ),
),

          const SizedBox(width: 8),

          // ➡️ right round action: mic (idle) → stop (recording) → send (has text/media)
          Container(
           decoration:  BoxDecoration(
  color: waGreen,
  shape: BoxShape.circle,
),

            child: IconButton(
              icon: Icon(_isRecording ? Icons.stop : (canSend ? Icons.send : Icons.mic), color: Colors.white),
              onPressed: () {
                if (_isRecording) {
                  _toggleRecord(); // stop -> creates audio chip
                } else if (canSend) {
                  _sendMessage();
                } else {
                  _toggleRecord(); // start recording
                }
              },
              tooltip: _isRecording ? 'Stop' : (canSend ? 'Send' : 'Record'),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Preview chips ───────────────────────
  Widget _mediaPreviewChip() {
    final isImage = _selectedType == 'image';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage
                ? Image.file(_selectedFile!, width: 56, height: 56, fit: BoxFit.cover)
                : Container(
                    width: 72, height: 48, color: Colors.black,
                    child: const Icon(Icons.play_circle_fill, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Attachment selected',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
            onPressed: _clearPendingMedia,
            tooltip: 'Remove',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
Widget _recordingChip() {
  final pulse = 1.0 + (_amp * 0.25); // 1..1.25 based on mic level
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.red.withOpacity(0.25)),
    ),
    child: Row(
      children: [
        AnimatedScale(
          scale: pulse,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 18, height: 18,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _mmss(_elapsed),
          style: const TextStyle(
            fontFeatures: [FontFeature.tabularFigures()],
            color: Colors.red, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        _Bars(level: _amp),
      ],
    ),
  );
}

  Widget _audioPreviewChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('• ${_mmss(_lastRecordedSecs)}',
              style: TextStyle(color: Colors.grey.shade800)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
            onPressed: _clearPendingMedia,
            tooltip: 'Discard',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
}

class _Bars extends StatelessWidget {
  final double level; // 0..1
  const _Bars({required this.level});
  @override
  Widget build(BuildContext context) {
    const m = [0.3, 0.7, 0.5, 1.0, 0.8, 0.6, 0.9, 0.4];
    return Row(
      children: List.generate(m.length, (i) {
        final h = 6 + 18 * (level * m[i]); // 6..24
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 3, height: h,
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2)),
        );
      }),
    );
  }
}

// ───────────────────────── Utilities ─────────────────────────
String _formatTime(String? timestamp) {
  if (timestamp == null || timestamp.isEmpty) return "No time";
  try {
    final utc = DateTime.parse(timestamp).toUtc();
    final ist = utc.add(const Duration(hours: 5, minutes: 30));
    final now = DateTime.now();
    final diff = now.difference(ist);

    if (diff.inMinutes <= 1) return "1 min ago";
    if (diff.inMinutes <= 2) return "2 min ago";
    if (diff.inMinutes <= 3) return "3 min ago";
    if (diff.inMinutes <= 5) return "5 min ago";
    if (diff.inMinutes <= 10) return "10 min ago";
    if (diff.inMinutes <= 30) return "Half hour ago";
    if (diff.inDays == 1) return "Yesterday";

    final dayDate = DateFormat('E d MMM').format(ist);
    final time = DateFormat('h:mm a').format(ist);
    return "$dayDate, $time";
  } catch (_) {
    return "Invalid time";
  }
}

class _Pick extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Pick({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Container(
              width: 68, height: 68,
              decoration: const BoxDecoration(color: Color(0xFFF0F2F6), shape: BoxShape.circle),
              child: Icon(icon, size: 30, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Full-screen image gallery (reuse your previous one)
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
  double _rotationAngle = 0.0;

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
            onPageChanged: (i) {
              setState(() {
                currentIndex = i;
                _rotationAngle = 0;
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
                      fit: BoxFit.contain,
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              '${currentIndex + 1}/${widget.images.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black45,
              onPressed: _rotateImage,
              child: const Icon(Icons.rotate_right, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
