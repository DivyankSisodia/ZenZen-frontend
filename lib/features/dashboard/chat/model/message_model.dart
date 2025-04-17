
class MessageModel {
  final String? id;
  final String? roomId;
  final String? chatRoom;
  final List<Chats>? chats;
   final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    this.id,
    this.roomId,
    this.chatRoom,
    this.chats,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      roomId: json['roomId'] ?? '',
      chatRoom: json['chatRoom'] ?? '',
      chats: json['chats'] != null
          ? (json['chats'] as List)
              .map((chatJson) => Chats.fromJson(chatJson))
              .toList()
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'roomId': roomId,
      'chatRoom': chatRoom,
      'chats': chats?.map((chat) => chat.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  MessageModel copyWith({
    String? roomId,
    String? chatRoom,
    List<Chats>? chats, DateTime? updatedAt,
  }) {
    return MessageModel(
      id: this.id,
      roomId: roomId ?? this.roomId,
      chatRoom: chatRoom ?? this.chatRoom,
      chats: chats ?? this.chats,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    );
  }
}

class Chats {
  final String sender; // Changed from senderId to sender to match API
  final String content;
  final MediaData? mediaData;
  final DateTime? timestamp;
  final String? messageType;
  final bool? isDeleted;
  final bool? isEdited;
  final DateTime? editedAt;
  final String? replyTo;
  final ReplyModel? replyMessage;
  final List<ReactionModel>? reactions; // Changed from reaction to reactions
  final bool? isSystemMessage;
  final List<ReadByModel>? readBy; // Changed to List<ReadByModel>

  Chats({
    required this.sender,
    required this.content,
    this.mediaData,
    this.timestamp,
    this.messageType,
    this.isDeleted,
    this.isEdited,
    this.editedAt,
    this.replyTo,
    this.replyMessage,
    this.reactions,
    this.isSystemMessage,
    this.readBy
  });

  factory Chats.fromJson(Map<String, dynamic> json) {
    return Chats(
      sender: json['sender'] ?? '',
      content: json['content'] ?? '',
      mediaData: json['mediaData'] != null
          ? MediaData.fromJson(json['mediaData'])
          : null,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      messageType: json['messageType'] ?? '',
      isDeleted: json['isDeleted'],
      isEdited: json['isEdited'],
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'])
          : null,
      replyTo: json['replyTo'],
      replyMessage: json['replyMessage'] != null
          ? ReplyModel.fromJson(json['replyMessage'])
          : null,
      reactions: (json['reactions'] as List?)
          ?.map((e) => ReactionModel.fromJson(e))
          .toList(),
      isSystemMessage: json['isSystemMessage'],
      readBy: (json['readBy'] as List?)
          ?.map((e) => ReadByModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
      'mediaData': mediaData?.toJson(),
      'timestamp': timestamp?.toIso8601String(),
      'messageType': messageType,
      'isDeleted': isDeleted,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'replyTo': replyTo,
      'replyMessage': replyMessage?.toJson(),
      'reactions': reactions?.map((e) => e.toJson()).toList(),
      'isSystemMessage': isSystemMessage,
      'readBy': readBy?.map((e) => e.toJson()).toList(),
    };
  }
}

class ReadByModel{
  final String? user;
  final DateTime? readAt;
  ReadByModel({
    this.user,
    this.readAt
  });
  factory ReadByModel.fromJson(Map<String, dynamic> json) {
    return ReadByModel(
      user: json['user'] ?? '',
      readAt: DateTime.parse(json['readAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'readAt': readAt?.toIso8601String(),
    };
  }
}

class ReplyModel {
  final String? content;
  final String? sender;
  final String? messageType;
  ReplyModel({
    this.content,
    this.sender,
    this.messageType
  });
  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      content: json['content'] ?? '',
      sender: json['sender'] ?? '',
      messageType: json['messageType'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'messageType': messageType,
    };
  }
}

class ReactionModel{
  final String? emoji;
  final String? userId;
  final DateTime? createdAt;
  ReactionModel({
    this.emoji,
    this.userId,
    this.createdAt
  });
  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      emoji: json['emoji'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userId': userId,
      'timestamp': createdAt?.toIso8601String(),
    };
  }
}

class MediaData {
  final String url;
  final String thumbnailUrl;
  final String fileName;
  final int fileSize;
  final int? duration; // for audio/video
  final Dimensions? dimensions;

  MediaData({
    required this.url,
    required this.thumbnailUrl,
    required this.fileName,
    required this.fileSize,
    this.duration,
    this.dimensions,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) {
    return MediaData(
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      fileName: json['fileName'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      duration: json['duration'],
      dimensions: json['dimensions'] != null
          ? Dimensions.fromJson(json['dimensions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
      'dimensions': dimensions?.toJson(),
    };
  }
}

class Dimensions {
  final int width;
  final int height;

  Dimensions({
    required this.width,
    required this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}
