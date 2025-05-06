// To parse this JSON data, do
//
//     final chatsModel = chatsModelFromJson(jsonString);

import 'dart:convert';

ChatsModel chatsModelFromJson(String str) =>
    ChatsModel.fromJson(json.decode(str));

String chatsModelToJson(ChatsModel data) => json.encode(data.toJson());

class ChatsModel {
  int? id;
  int? roomId;
  String? message;
  dynamic file;
  String? createdAt;
  String? updatedAt;
  int? senderId;
  Sender? sender;
  dynamic fileType;

  ChatsModel({
    this.id,
    this.roomId,
    this.message,
    this.file,
    this.createdAt,
    this.updatedAt,
    this.senderId,
    this.sender,
    this.fileType,
  });

  factory ChatsModel.fromJson(Map<String, dynamic> json) => ChatsModel(
    id: json["id"],
    roomId: json["room_id"],
    message: json["message"],
    file: json["file"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    senderId: json["sender_id"],
    sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
    fileType: json["file_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "room_id": roomId,
    "message": message,
    "file": file,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "sender_id": senderId,
    "sender": sender?.toJson(),
    "file_type": fileType,
  };
}

class Sender {
  int? senderId;
  String? name;
  int? roleId;

  Sender({this.senderId, this.name, this.roleId});

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    senderId: json["sender_id"],
    name: json["name"],
    roleId: json["role_id"],
  );

  Map<String, dynamic> toJson() => {
    "sender_id": senderId,
    "name": name,
    "role_id": roleId,
  };
}
