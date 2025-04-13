// class ChatModel {
//   final String id;
//   final String userId;
//   final String userName;
//   final String? userAvatar;
//   final String lastMessage;
//   final DateTime lastMessageTime;
//   final bool isRead;
//   final int unreadCount;

//   ChatModel({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     this.userAvatar,
//     required this.lastMessage,
//     required this.lastMessageTime,
//     required this.isRead,
//     required this.unreadCount,
//   });

//   factory ChatModel.fromJson(Map<String, dynamic> json) {
//     return ChatModel(
//       id: json['id'] ?? '',
//       userId: json['userId'] ?? '',
//       userName: json['userName'] ?? '',
//       userAvatar: json['userAvatar'],
//       lastMessage: json['lastMessage'] ?? '',
//       lastMessageTime: json['lastMessageTime'] != null
//           ? DateTime.parse(json['lastMessageTime'])
//           : DateTime.now(),
//       isRead: json['isRead'] ?? false,
//       unreadCount: json['unreadCount'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'userName': userName,
//       'userAvatar': userAvatar,
//       'lastMessage': lastMessage,
//       'lastMessageTime': lastMessageTime.toIso8601String(),
//       'isRead': isRead,
//       'unreadCount': unreadCount,
//     };
//   }

//   ChatModel copyWith({
//     String? id,
//     String? userId,
//     String? userName,
//     String? userAvatar,
//     String? lastMessage,
//     DateTime? lastMessageTime,
//     bool? isRead,
//     int? unreadCount,
//   }) {
//     return ChatModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       userName: userName ?? this.userName,
//       userAvatar: userAvatar ?? this.userAvatar,
//       lastMessage: lastMessage ?? this.lastMessage,
//       lastMessageTime: lastMessageTime ?? this.lastMessageTime,
//       isRead: isRead ?? this.isRead,
//       unreadCount: unreadCount ?? this.unreadCount,
//     );
//   }
// } 

import 'package:zenzen/features/auth/login/model/user_model.dart';

class ChatRoom{
  final String? roomId;
  final String? chatType;
  final List<Participants>? participants;
  final LastMessageModel? lastMessage;
  final UserModel? creater;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? callStatus;

  ChatRoom({
    this.roomId,
    this.chatType,
     this.participants,
    this.lastMessage,
     this.creater,
     this.createdAt,
     this.updatedAt,
    this.callStatus
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: json['roomId'] ?? '',
      chatType: json['chatType'] ?? '',
      participants: (json['participants'] as List)
          .map((e) => Participants.fromJson(e))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? LastMessageModel.fromJson(json['lastMessage'])
          : null,
      creater: UserModel.fromJson(json['creater']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      callStatus: json['callStatus'],
    );
  }

  ChatRoom copyWith({
    String? roomId,
    String? chatType,
    List<Participants>? participants,
    LastMessageModel? lastMessage,
    UserModel? creater,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? callStatus
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      chatType: chatType ?? this.chatType,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      creater: creater ?? this.creater,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      callStatus: callStatus ?? this.callStatus
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'chatType': chatType,
      'participants': participants!.map((e) => e.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'creater': creater!.toJson(),
      'createdAt': createdAt!.toIso8601String(),
      'updatedAt': updatedAt!.toIso8601String(),
      'callStatus': callStatus,
    };
  }
}

class Participants{
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final DateTime? lastReadMessageTime;
  final int? unreadCount;
  final DateTime? joinedAt;

  Participants({
    this.userId,
    this.userName,
    this.userAvatar,
    this.lastReadMessageTime,
    this.unreadCount,
    this.joinedAt
  });

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      lastReadMessageTime: json['lastReadMessageTime'] != null
          ? DateTime.parse(json['lastReadMessageTime'])
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'lastReadMessageTime': lastReadMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }
}

class LastMessageModel{
  final String? content;
  final String? sender;
  final DateTime? timestamp;

  LastMessageModel({
    this.content,
    this.sender,
    this.timestamp
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      content: json['content'] ?? '',
      sender: json['sender'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}