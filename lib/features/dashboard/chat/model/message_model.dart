import 'package:zenzen/features/dashboard/chat/model/chat_model.dart';

class MessageModel {
  final String roomId;
  final ChatRoom chatRoom;
  final String senderId;
  final String content;
  final MediaData? mediaData;
  final DateTime timestamp;
  final String? messageType;
  final bool? isDeleted;
  final bool? isEdited;
  final DateTime? editedAt;
  final String? replyTo;
  final ReplyModel? replyMessage;
  final List<ReactionModel>? reaction;
  final bool? isSystemMessage;
  final ReadByModel? readBy;

  MessageModel({
    required this.roomId,
    required this.chatRoom,
    required this.senderId,
    required this.content,
    this.mediaData,
    required this.timestamp,
    this.messageType,
    this.isDeleted,
    this.isEdited,
    this.editedAt,
    this.replyTo,
    this.replyMessage,
    this.reaction,
    this.isSystemMessage,
    this.readBy
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      roomId: json['roomId'] ?? '',
      chatRoom: ChatRoom.fromJson(json['chatRoom']),
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      mediaData: json['mediaData'] != null
          ? MediaData.fromJson(json['mediaData'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
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
      reaction: (json['reaction'] as List?)
          ?.map((e) => ReactionModel.fromJson(e))
          .toList(),
      isSystemMessage: json['isSystemMessage'],
      readBy: json['readBy'] != null
          ? ReadByModel.fromJson(json['readBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'chatRoom': chatRoom.toJson(),
      'senderId': senderId,
      'content': content,
      'mediaData': mediaData?.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType,
      'isDeleted': isDeleted,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'replyTo': replyTo,
      'replyMessage': replyMessage?.toJson(),
      'reaction': reaction?.map((e) => e.toJson()).toList(),
      'isSystemMessage': isSystemMessage,
      'readBy': readBy?.toJson(),
    };
  }
  MessageModel copyWith({
    String? roomId,
    ChatRoom? chatRoom,
    String? senderId,
    String? content,
    MediaData? mediaData,
    DateTime? timestamp,
    String? messageType,
    bool? isDeleted,
    bool? isEdited,
    DateTime? editedAt,
    String? replyTo,
    ReplyModel? replyMessage,
    List<ReactionModel>? reaction,
    bool? isSystemMessage,
    ReadByModel? readBy
  }) {
    return MessageModel(
      roomId: roomId ?? this.roomId,
      chatRoom: chatRoom ?? this.chatRoom,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      mediaData: mediaData ?? this.mediaData,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      replyTo: replyTo ?? this.replyTo,
      replyMessage: replyMessage ?? this.replyMessage,
      reaction: reaction ?? this.reaction,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      readBy: readBy ?? this.readBy
    );
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
