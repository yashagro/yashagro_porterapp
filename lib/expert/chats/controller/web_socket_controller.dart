import 'dart:developer';
import 'package:get/get.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/expert/chats/controller/chats_controller.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/models/chats_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketController extends GetxController {
  IO.Socket? socket;
  String authToken = '';

  @override
  void onInit() {
    super.onInit();
    getTokenAndConnect();
  }

  /// **🔹 Fetch JWT Token & Connect to WebSocket**
  void getTokenAndConnect() async {
    authToken = await SharedPrefs.getUserToken() ?? '';
    if (authToken.isNotEmpty) {
      connectToWebSocket();
    }
  }

  /// **🔹 Connect to WebSocket Server**
  void connectToWebSocket() {
    if (socket != null && socket!.connected) {
      log('✅ WebSocket already connected', name: 'websocket');
      return;
    }

    
    String baseUrl = ApiRoutes.baseUri;

    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': authToken},
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    socket!.onConnect((_) {
      log('✅ WebSocket Connected', name: 'websocket');
      listenForMessages();
    });

    socket!.onDisconnect(
      (_) => log('❌ WebSocket Disconnected', name: 'websocket'),
    );

    socket!.onError(
      (data) => log('⚠️ WebSocket Error: $data', name: 'websocket'),
    );

    socket!.connect();
  }

  /// **🔹 Join a Chat Room**
  void joinChat(String roomId) {
    if (socket != null && socket!.connected) {
      socket!.emit('joinRoom', {'roomId': roomId});
      log('📩 Joined chat room: $roomId', name: 'websocket');
    }
  }

  /// **🔹 Listen for Incoming Messages**
  void listenForMessages() {
    socket!.on('receiveMessage', (data) {
      log('📨 New Message Received: $data', name: 'websocket');
      ChatsModel receivedMessage = ChatsModel.fromJson(data);
      Get.find<ChatsController>().insertChat(receivedMessage);
    });
  }

  /// **🔹 Send a Message**
  void sendMessage(int roomId, String message, {String? filePath}) {
    if (socket != null && socket!.connected) {
      Map<String, dynamic> messageData = {
        'room_id': roomId,
        'message': message,
        'file': filePath ?? "",
      };
      socket!.emit('sendMessage', messageData);

      log('📤 Message Sent: $message', name: 'websocket');

      // ✅ **Manually Insert the Sent Message into UI**
    }
  }

  /// **🔹 Leave a Chat Room**
  void leaveChat(String roomId) {
    if (socket != null && socket!.connected) {
      socket!.emit('leaveRoom', {"roomId": roomId});
      log('🚪 Left chat room: $roomId', name: 'websocket');
    }
  }

  /// **🔹 Disconnect WebSocket on App Close**
  @override
  void onClose() {
    socket?.disconnect();
    socket = null;
    log('❌ WebSocket Disconnected on Close', name: 'websocket');
    super.onClose();
  }
}
