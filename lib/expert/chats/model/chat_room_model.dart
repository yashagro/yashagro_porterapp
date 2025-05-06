import 'dart:convert';

ChatRoomModel chatRoomModelFromJson(String str) => ChatRoomModel.fromJson(json.decode(str));

String chatRoomModelToJson(ChatRoomModel data) => json.encode(data.toJson());

class ChatRoomModel {
    int? id;
    String? status;
    String? createdAt;
    String? updatedAt;
    User? user;
    dynamic expert;
    Plot? plot;
    LastMessage? lastMessage;
    int? unseenMsgCount;

    ChatRoomModel({
        this.id,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.user,
        this.expert,
        this.plot,
        this.lastMessage,
        this.unseenMsgCount,
    });


    factory ChatRoomModel.fromJson(Map<String, dynamic> json) => ChatRoomModel(
        id: json["id"],
        status: json["status"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        expert: json["expert"],
        plot: json["plot"] == null ? null : Plot.fromJson(json["plot"]),
        lastMessage: json["last_message"] == null ? null : LastMessage.fromJson(json["last_message"]),
        unseenMsgCount: json["unseen_msg_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "user": user?.toJson(),
        "expert": expert,
        "plot": plot?.toJson(),
        "last_message": lastMessage?.toJson(),
        "unseen_msg_count": unseenMsgCount,
    };
}

class LastMessage {
    int? id;
    int? senderId;
    String? message;
    String? file;
    String? createdAt;

    LastMessage({
        this.id,
        this.senderId,
        this.message,
        this.file,
        this.createdAt,
    });

    factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        id: json["id"],
        senderId: json["sender_id"],
        message: json["message"],
        file: json["file"],
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sender_id": senderId,
        "message": message,
        "file": file,
        "created_at": createdAt,
    };
}

class Plot {
    int? id;
    String? name;

    Plot({
        this.id,
        this.name,
    });

    factory Plot.fromJson(Map<String, dynamic> json) => Plot(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class User {
    int? id;
    String? name;
    String? mobileNo;
    String? image;

    User({
        this.id,
        this.name,
        this.mobileNo,
        this.image,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        mobileNo: json["mobile_no"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mobile_no": mobileNo,
        "image": image,
    };
}
