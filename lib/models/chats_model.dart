import 'dart:convert';

class ChatsModel {
  int? id;
  int? roomId;
  int? senderId;
  String? message;
  String? file;
  String? createdAt;
  String? updatedAt;
  String? fileType;

  ChatsModel({
    this.id,
    this.roomId,
    this.senderId,
    this.message,
    this.file,
    this.createdAt,
    this.updatedAt,
    this.fileType,
  });

  factory ChatsModel.fromRawJson(String str) =>
      ChatsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChatsModel.fromJson(Map<String, dynamic> json) => ChatsModel(
        id: json["id"],
        roomId: json["room_id"],
        senderId: json["sender_id"],
        message: json["message"],
        file: json["file"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        fileType: json["file_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "room_id": roomId,
        "sender_id": senderId,
        "message": message,
        "file": file,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "file_type": fileType,
      };
}
