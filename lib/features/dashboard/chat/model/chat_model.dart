// import 'package:zenzen/features/auth/login/model/user_model.dart';

// class ChatRoom {
//   final String? roomId;
//   final String? chatType;
//   final List<Participants>? participants;
//   final int? unreadCount;
//   final LastMessageModel? lastMessage;
//   final UserModel? creater;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final bool? callStatus;

//   ChatRoom({this.roomId, this.chatType, this.participants, this.lastMessage, this.creater, this.createdAt, this.updatedAt, this.callStatus, this.unreadCount});

//   factory ChatRoom.fromJson(Map<String, dynamic> json) {
//     try {
//       return ChatRoom(
//         roomId: json['roomId']?.toString() ?? '',
//         chatType: json['chatType']?.toString() ?? '',
//         participants: json['participants'] != null ? (json['participants'] as List).map((e) => e is Map<String, dynamic> ? Participants.fromJson(e) : Participants()).toList() : [],
//         lastMessage: json['lastMessage'] != null && json['lastMessage'] is Map ? LastMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>) : null,
//         creater: json['creater'] is Map ? UserModel.fromJson(json['creater'] as Map<String, dynamic>) : null,
//         createdAt: json['createdAt'] != null && json['createdAt'] is String ? DateTime.parse(json['createdAt']) : null,
//         updatedAt: json['updatedAt'] != null && json['updatedAt'] is String ? DateTime.parse(json['updatedAt']) : null,
//         callStatus: json['callStatus'] is bool ? json['callStatus'] : null,
//         unreadCount: json['unreadCount'] is int ? json['unreadCount'] : 0,
//       );
//     } catch (e) {
//       print('Error parsing ChatRoom: $e');
//       print('JSON data: $json');
//       // Return a default ChatRoom to avoid crashing
//       return ChatRoom();
//     }
//   }

//   ChatRoom copyWith({String? roomId, String? chatType, List<Participants>? participants, LastMessageModel? lastMessage, UserModel? creater, DateTime? createdAt, DateTime? updatedAt, bool? callStatus}) {
//     return ChatRoom(roomId: roomId ?? this.roomId, chatType: chatType ?? this.chatType, participants: participants ?? this.participants, lastMessage: lastMessage ?? this.lastMessage, creater: creater ?? this.creater, createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt, callStatus: callStatus ?? this.callStatus, unreadCount: unreadCount ?? this.unreadCount);
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'roomId': roomId,
//       'chatType': chatType,
//       'participants': participants!.map((e) => e.toJson()).toList(),
//       'lastMessage': lastMessage?.toJson(),
//       'creater': creater!.toJson(),
//       'createdAt': createdAt!.toIso8601String(),
//       'updatedAt': updatedAt!.toIso8601String(),
//       'callStatus': callStatus,
//       'unreadCount': unreadCount,
//     };
//   }
// }

// class Participants {
//   final String? userId;
//   final String? userName;
//   final String? userAvatar;
//   final DateTime? lastReadMessageTime;
//   final int? unreadCount;
//   final DateTime? joinedAt;

//   Participants({this.userId, this.userName, this.userAvatar, this.lastReadMessageTime, this.unreadCount, this.joinedAt});

//   factory Participants.fromJson(Map<String, dynamic> json) {
//     return Participants(
//       userId: json['userId'] ?? '',
//       userName: json['userName'] ?? '',
//       userAvatar: json['userAvatar'],
//       lastReadMessageTime: json['lastReadMessageTime'] != null ? DateTime.parse(json['lastReadMessageTime']) : DateTime.now(),
//       unreadCount: json['unreadCount'] ?? 0,
//       joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'userName': userName,
//       'userAvatar': userAvatar,
//       'lastReadMessageTime': lastReadMessageTime?.toIso8601String(),
//       'unreadCount': unreadCount,
//       'joinedAt': joinedAt?.toIso8601String(),
//     };
//   }
// }

// class LastMessageModel {
//   final String? content;
//   final Map<String, dynamic>? sender; // Changed from String to Map
//   final DateTime? timestamp;

//   LastMessageModel({this.content, this.sender, this.timestamp});

//   factory LastMessageModel.fromJson(Map<String, dynamic> json) {
//     try {
//       return LastMessageModel(
//         content: json['content']?.toString() ?? '',
//         sender: json['sender'] is Map ? json['sender'] as Map<String, dynamic> : null,
//         timestamp: json['timestamp'] != null && json['timestamp'] is String ? DateTime.parse(json['timestamp']) : null,
//       );
//     } catch (e) {
//       print('Error parsing LastMessageModel: $e');
//       return LastMessageModel();
//     }
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'content': content,
//       'sender': sender,
//       'timestamp': timestamp?.toIso8601String(),
//     };
//   }

//   // Helper methods to extract sender info
//   String? get senderId => sender != null ? sender!['_id']?.toString() ?? sender!['id']?.toString() : null;
//   String? get senderName => sender != null ? sender!['userName']?.toString() : null;
// }

// extension JsonDebug on Map<String, dynamic> {
//   void printTypes() {
//     forEach((key, value) {
//       print('Field: $key, Type: ${value?.runtimeType}, Value: $value');
//     });
//   }
// }


class ChatRoom {
  final String? id;
  final String? roomId;
  final String? chatType;
  final List<Participants>? participants;
  final int? unreadCount;
  final LastMessageModel? lastMessage;
  final String? createdBy; // Changed from UserModel to String
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? callStatus;

  ChatRoom({
    this.id, // Added to store the _id field
    this.roomId, 
    this.chatType, 
    this.participants, 
    this.lastMessage, 
    this.createdBy, // Changed from creater to createdBy
    this.createdAt, 
    this.updatedAt, 
    this.callStatus, 
    this.unreadCount
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    try {
      // Extract the unread count from the current user's participant entry
      int extractedUnreadCount = 0;
      if (json['participants'] != null && json['participants'] is List) {
        // Take the first participant's unread count as default
        // In a real app, you might want to find the current user's entry instead
        if ((json['participants'] as List).isNotEmpty) {
          extractedUnreadCount = (json['participants'][0]['unreadCount'] ?? 0) as int;
        }
      }

      return ChatRoom(
        id: json['_id']?.toString() ?? '',
        roomId: json['roomId']?.toString() ?? '',
        chatType: json['chatType']?.toString() ?? '',
        participants: json['participants'] != null 
          ? (json['participants'] as List).map((e) => 
              e is Map<String, dynamic> ? Participants.fromJson(e) : Participants())
            .toList() 
          : [],
        lastMessage: json['lastMessage'] != null 
          ? LastMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>) 
          : null,
        createdBy: json['createdBy']?.toString(), // Changed from creater to createdBy
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        callStatus: json['callStatus'] is bool ? json['callStatus'] : false,
        unreadCount: json['unreadCount'] is int ? json['unreadCount'] : extractedUnreadCount,
      );
    } catch (e) {
      print('Error parsing ChatRoom: $e');
      print('JSON data: $json');
      // Return a default ChatRoom to avoid crashing
      return ChatRoom();
    }
  }

  ChatRoom copyWith({
    String? roomId, 
    String? chatType, 
    List<Participants>? participants, 
    LastMessageModel? lastMessage, 
    String? createdBy, 
    DateTime? createdAt, 
    DateTime? updatedAt, 
    bool? callStatus,
    int? unreadCount
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId, 
      chatType: chatType ?? this.chatType, 
      participants: participants ?? this.participants, 
      lastMessage: lastMessage ?? this.lastMessage, 
      createdBy: createdBy ?? this.createdBy, 
      createdAt: createdAt ?? this.createdAt, 
      updatedAt: updatedAt ?? this.updatedAt, 
      callStatus: callStatus ?? this.callStatus,
      unreadCount: unreadCount ?? this.unreadCount
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'roomId': roomId,
      'chatType': chatType,
      'participants': participants?.map((e) => e.toJson()).toList() ?? [],
      'lastMessage': lastMessage?.toJson(),
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'callStatus': callStatus,
      'unreadCount': unreadCount,
    };
  }
}

class Participants {
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final DateTime? lastReadMessageTime;
  final int? unreadCount;
  final DateTime? joinedAt;
  final String? id; // Added to store the _id field

  Participants({
    this.userId, 
    this.userName, 
    this.userAvatar, 
    this.lastReadMessageTime, 
    this.unreadCount, 
    this.joinedAt,
    this.id
  });

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString(),
      lastReadMessageTime: json['lastReadMessageTime'] != null 
        ? DateTime.parse(json['lastReadMessageTime']) 
        : DateTime.now(),
      unreadCount: json['unreadCount'] is int ? json['unreadCount'] : 0,
      joinedAt: json['joinedAt'] != null 
        ? DateTime.parse(json['joinedAt']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'lastReadMessageTime': lastReadMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }
}

class LastMessageModel {
  final String? content;
  final String? sender; // Changed back to String as in the API
  final DateTime? timestamp;

  LastMessageModel({this.content, this.sender, this.timestamp});

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    try {
      return LastMessageModel(
        content: json['content']?.toString() ?? '',
        sender: json['sender']?.toString() ?? '',
        timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : null,
      );
    } catch (e) {
      print('Error parsing LastMessageModel: $e');
      return LastMessageModel();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}