import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/data/sockets/socket_repo.dart';
import 'package:zenzen/features/dashboard/chat/model/message_model.dart';
import 'package:zenzen/features/dashboard/chat/widgets/chat_bubble_widget.dart';
import 'package:image/image.dart' as img;

import '../../../../data/local/hive_models/local_user_model.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../provider/typing_provider.dart';
import '../view-model/chat_viewmodel.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final String? id;
  final String? chatRoomId;
  final String? chatName;
  final String? chatImage;
  const ChatListScreen({super.key, this.chatRoomId, this.chatName, this.chatImage, this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  LocalUser? currentuser;
  String? roomId;
  bool _didInitialize = false;
  final TextEditingController _messageController = TextEditingController();
  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the same provider that your UI is watching
      ref.read(chatViewModelProvider.notifier).getChatMessages(widget.id!);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialize) {
      getCurrentUser();
      _didInitialize = true;
    }
    onChangedMessages();
    listenForTypingIndicators();
  }

  void getCurrentUser() {
    final hiveService = ref.read(userDataProvider);
    final user = hiveService.userBox.get('currentUser');
    if (mounted) {
      setState(() {
        currentuser = user;
        if (widget.chatRoomId != null && currentuser != null) {
          roomId = widget.chatRoomId;
          print('Chat ID: $roomId');
          joinChat();
        }
      });
    }
  }

  void joinChat() {
    ref.read(socketRepoProvider).joinChatRoom({
      'roomId': roomId,
      'userId': currentuser!.id,
    });
  }

  // void onChangedMessages() {
  //   ref.read(socketRepoProvider).onChatMessage((data) {
  //     print('New message received: $data');

  //     MediaData? mediaData;
  //     if (data['messageType'] == 'image' && data['mediaData'] != null) {
  //       final compressedBase64 = data['mediaData'] as String;
  //       final decompressedBytes = decompressBase64(compressedBase64);
  //       if (decompressedBytes != null) {
  //         // Convert decompressed bytes back to Base64 for the url field
  //         final decompressedBase64 = base64Encode(decompressedBytes);
  //         mediaData = MediaData(
  //           url: 'data:image/jpeg;base64,$decompressedBase64', // Example MIME type
  //           thumbnailUrl: 'data:image/jpeg;base64,$decompressedBase64', // Same for thumbnail
  //           fileName: 'image.jpg', // Adjust as needed
  //           fileSize: decompressedBytes.length,
  //           dimensions: Dimensions(width: 0, height: 0), // Set actual dimensions if available
  //         );
  //         print('Decompressed media data size: ${decompressedBytes.length} bytes');
  //       }
  //     }

  //     final chat = Chats(
  //       sender: data['sender'] as String,
  //       content: data['message'] as String,
  //       timestamp: DateTime.parse(data['timestamp'] as String),
  //       messageType: data['messageType'] as String?,
  //       mediaData: mediaData, // Assign the constructed MediaData object
  //       isDeleted: false,
  //       isEdited: false,
  //       isSystemMessage: false,
  //       readBy: [],
  //       reactions: [],
  //       replyMessage: null,
  //       replyTo: null,
  //       editedAt: null,
  //     );
  //     print('Created Chats: ${chat.toJson()}');

  //     final MessageModel message = MessageModel(
  //       id: null,
  //       roomId: data['roomId'] as String?,
  //       chatRoom: null,
  //       chats: [chat],
  //       createdAt: DateTime.parse(data['timestamp'] as String),
  //       updatedAt: DateTime.parse(data['timestamp'] as String),
  //     );

  //     if (roomId != null) {
  //       ref.read(chatViewModelProvider.notifier).addMessage(message);
  //       // Scroll to bottom (uncomment if needed)
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         if (_scrollController.hasClients) {
  //           _scrollController.animateTo(
  //             _scrollController.position.maxScrollExtent,
  //             duration: Duration(milliseconds: 300),
  //             curve: Curves.easeOut,
  //           );
  //         }
  //       });
  //     }
  //   });
  // }

  void onChangedMessages() {
    ref.read(socketRepoProvider).onChatMessage((data) {
      print('New message received: $data');

      if (!mounted) return;

      MediaData? mediaData;
      final messageType = data['messageType'] as String?;

      // Handle media types (image, video, audio, file)
      if (messageType != null && messageType != 'text' && data['mediaData'] != null) {
        // Check if mediaData is a Map or a String
        if (data['mediaData'] is Map) {
          final mediaDataMap = data['mediaData'] as Map<String, dynamic>;

          mediaData = MediaData(
            url: mediaDataMap['url'] as String? ?? '',
            thumbnailUrl: null, // No thumbnail as requested
            fileName: mediaDataMap['fileName'] as String? ?? 'file',
            fileSize: mediaDataMap['fileSize'] as int? ?? 0,
            dimensions: Dimensions(width: mediaDataMap['dimensions'] != null ? (mediaDataMap['dimensions'] as Map<String, dynamic>)['width'] as int? ?? 0 : 0, height: mediaDataMap['dimensions'] != null ? (mediaDataMap['dimensions'] as Map<String, dynamic>)['height'] as int? ?? 0 : 0),
          );
        } else if (data['mediaData'] is String) {
          // Handle the old format for backward compatibility
          final compressedBase64 = data['mediaData'] as String;
          final decompressedBytes = decompressBase64(compressedBase64);
          if (decompressedBytes != null) {
            final decompressedBase64 = base64Encode(decompressedBytes);

            // Determine mime type based on message type
            String mimeType = 'application/octet-stream';
            String fileName = 'file';

            switch (messageType) {
              case 'image':
                mimeType = 'image/jpeg';
                fileName = 'image.jpg';
                break;
              case 'video':
                mimeType = 'video/mp4';
                fileName = 'video.mp4';
                break;
              case 'audio':
                mimeType = 'audio/mp3';
                fileName = 'audio.mp3';
                break;
            }

            mediaData = MediaData(
              url: 'data:$mimeType;base64,$decompressedBase64',
              thumbnailUrl: null, // No thumbnail
              fileName: fileName,
              fileSize: decompressedBytes.length,
              dimensions: Dimensions(width: 0, height: 0),
            );
          }
        }
      }

      // Rest of your code remains the same...
      final chat = Chats(
        sender: data['sender'] as String,
        content: data['message'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
        messageType: messageType,
        mediaData: mediaData,
        isDeleted: false,
        isEdited: false,
        isSystemMessage: false,
        readBy: [],
        reactions: [],
        replyMessage: null,
        replyTo: null,
        editedAt: null,
      );

      // Continue with the rest of your function...
      if (roomId != null) {
        final message = MessageModel(
          id: null,
          roomId: data['roomId'] as String?,
          chatRoom: null,
          chats: [chat],
          createdAt: DateTime.parse(data['timestamp'] as String),
          updatedAt: DateTime.parse(data['timestamp'] as String),
        );

        ref.read(chatViewModelProvider.notifier).addMessage(message);
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

// Function to decompress Base64
  Uint8List? decompressBase64(String compressedBase64) {
    try {
      final compressedBytes = base64Decode(compressedBase64);
      final decoder = ZLibDecoder();
      final decompressedBytes = decoder.decodeBytes(compressedBytes);
      return Uint8List.fromList(decompressedBytes);
    } catch (e) {
      print('Error decompressing: $e');
      return null;
    }
  }

  void onSendMessage(String messageText) {
    if (!mounted) return;
    if (roomId != null && currentuser != null && messageText.isNotEmpty) {
      // Get current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create the message object to send
      final messageData = {
        'roomId': roomId!,
        'userId': currentuser!.id, // Your server handles either userId or sender
        'message': messageText,
        'type': 'text', // Your server handles either type or messageType
      };

      // Send via socket
      ref.read(socketRepoProvider).sendChatMessage(messageData);

      // Create local message model for our UI
      final newMessage = MessageModel(
        chatRoom: widget.id!,
        roomId: roomId!,
        chats: [
          Chats(
            sender: currentuser!.id!,
            content: messageText,
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            messageType: 'text',
          )
        ],
      );

      // Add to our local state
      ref.read(chatViewModelProvider.notifier).addMessage(newMessage);

      // scroll chat to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void listenForTypingIndicators() {
    if (!mounted) return;
    ref.read(socketRepoProvider).onUserTyping((data) {
      final userId = data['userId'] as String;
      final roomId = data['roomId'] as String;
      // Assume typing is true when the event is received
      final isTyping = data['isTyping'] as bool? ?? true;

      ref.read(typingUsersProvider(roomId).notifier).setTyping(userId, roomId, isTyping);
    });
  }

  // Function 1: Pick file and return file information
  // Function 1: Pick file and return file information
  Future<Map<String, dynamic>?> pickMediaFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        allowCompression: true,
        compressionQuality: 10,
      );

      if (result == null) {
        print('No file selected');
        return null;
      }

      final file = result.files.single;

      // Check file size before proceeding - 1MB limit
      // if (file.size > 1 * 1024 * 1024) {
      //   // Show toast message
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Cannot send files larger than 1MB'),
      //       duration: Duration(seconds: 3),
      //     ),
      //   );
      //   return null;
      // }

      Uint8List fileBytes;
      String fileName = file.name;
      int fileSize = file.size;
      String mimeType = '';
      int width = 0;
      int height = 0;

      // Get file bytes
      if (kIsWeb) {
        if (file.bytes == null) {
          print('Error: No bytes found for web file.');
          return null;
        }
        fileBytes = file.bytes!;
        fileSize = fileBytes.length;
      } else {
        if (file.path == null) {
          print('Error: No file path found for mobile file.');
          return null;
        }
        File fileObj = File(file.path!);
        fileBytes = await fileObj.readAsBytes();
        fileSize = fileBytes.length;
      }

      // Rest of your code remains the same...
      // Determine mime type and message type
      final extension = fileName.split('.').last.toLowerCase();
      String messageType = 'file';
      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        mimeType = 'image/${extension == 'jpg' ? 'jpeg' : extension}';
        messageType = 'image';
      } else if (['mp4', 'mov', 'avi', 'webm', 'mkv'].contains(extension)) {
        mimeType = 'video/${extension}';
        messageType = 'video';
      } else if (['mp3', 'wav', 'ogg', 'm4a', 'aac'].contains(extension)) {
        mimeType = 'audio/${extension}';
        messageType = 'audio';
      } else {
        mimeType = 'application/octet-stream';
        messageType = 'file';
      }

      // Compress and resize images to ~50KB
      if (messageType == 'image') {
        try {
          // Decode image to get dimensions
          final decodedImage = img.decodeImage(fileBytes);
          if (decodedImage == null) {
            print('Error decoding image');
            return null;
          }
          width = decodedImage.width;
          height = decodedImage.height;

          // Resize if dimensions are large (600px for web, 800px for mobile)
          final maxWidth = kIsWeb ? 600 : 800;
          if (width > maxWidth) {
            final newHeight = (height * maxWidth / width).round();
            final resizedImage = img.copyResize(
              decodedImage,
              width: maxWidth,
              height: newHeight,
              interpolation: img.Interpolation.average,
            );
            fileBytes = Uint8List.fromList(
              img.encodeJpg(resizedImage, quality: kIsWeb ? 75 : 85),
            );
            width = maxWidth;
            height = newHeight;
          }

          // Compress to target size (~50KB)
          const targetSize = 50 * 1024; // 50KB in bytes
          int quality = kIsWeb ? 75 : 90;
          fileSize = fileBytes.length;

          if (fileSize > targetSize) {
            if (kIsWeb) {
              // Web: Fallback to image package compression
              while (fileSize > targetSize && quality > 10) {
                final compressedImage = img.decodeImage(fileBytes);
                if (compressedImage == null) {
                  print('Error decoding image for compression');
                  return null;
                }
                fileBytes = Uint8List.fromList(
                  img.encodeJpg(compressedImage, quality: quality),
                );
                fileSize = fileBytes.length;
                quality -= 10;
              }
            } else {
              // Mobile: Use flutter_image_compress
              while (fileSize > targetSize && quality > 10) {
                fileBytes = await FlutterImageCompress.compressWithList(
                  fileBytes,
                  quality: quality,
                  format: extension == 'png' ? CompressFormat.png : CompressFormat.jpeg,
                );
                fileSize = fileBytes.length;
                quality -= 10;
              }
            }
          }

          if (fileSize > targetSize) {
            print('Warning: Could not compress image below 50KB. Current size: ${fileSize / 1024}KB');
          }
        } catch (e) {
          print('Error processing image: $e');
          return null;
        }
      }

      // Create base64 URL for immediate display (optional, for UI preview)
      final base64String = base64Encode(fileBytes);
      final dataUrl = 'data:$mimeType;base64,$base64String';

      return {
        'fileName': fileName,
        'fileSize': fileSize,
        'mimeType': mimeType,
        'messageType': messageType,
        'width': width,
        'height': height,
        'dataUrl': dataUrl,
        'fileBytes': fileBytes,
      };
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

// Function 2: Send file to server and update UI
  void sendFileAndUpdateUI(WidgetRef ref, String? roomId, String? userId, Map<String, dynamic> fileData) async {
    if (roomId == null || userId == null) {
      print('Room ID or User ID missing');
      return;
    }

    try {
      final String messageType = fileData['messageType'];
      final String dataUrl = fileData['dataUrl'];
      final String fileName = fileData['fileName'];
      final int fileSize = fileData['fileSize'];
      final String mimeType = fileData['mimeType'];
      final int width = fileData['width'];
      final int height = fileData['height'];

      // Send to server
      ref.read(socketRepoProvider).sendChatMessage({
        'roomId': roomId,
        'message': _getMessageContentByType(messageType),
        'sender': userId,
        'messageType': messageType,
        'mediaData': {
          'url': dataUrl,
          'thumbnailUrl': null, // Leave thumbnail as null
          'fileName': fileName,
          'fileSize': fileSize,
          'mimeType': mimeType,
          'dimensions': {'width': width, 'height': height},
        },
        'timestamp': DateTime.now().toIso8601String(),
      });

      print('socket event ke baad ka print');

      // Update the local UI state
      final mediaData = MediaData(
        url: dataUrl,
        thumbnailUrl: null, // No thumbnail
        fileName: fileName,
        fileSize: fileSize,
        dimensions: Dimensions(width: width, height: height),
      );

      final newMessage = MessageModel(
        chatRoom: widget.id!,
        roomId: roomId,
        chats: [
          Chats(
            sender: userId,
            content: _getMessageContentByType(messageType),
            timestamp: DateTime.now(),
            messageType: messageType,
            mediaData: mediaData,
          )
        ],
      );

      // Add to local state
      ref.read(chatViewModelProvider.notifier).addMessage(newMessage);
    } catch (e) {
      print('Error sending file: $e');
    }
  }

  String _getMessageContentByType(String messageType) {
    switch (messageType) {
      case 'image':
        return 'Image sent';
      case 'video':
        return 'Video sent';
      case 'audio':
        return 'Audio sent';
      default:
        return 'File sent';
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel(); // Cancel typing timer
    _messageController.dispose();

    // Remove socket listeners
    ref.read(socketRepoProvider).removeUserTypingListener();
    ref.read(socketRepoProvider).removeChatMessageListener();

    // Leave chat room
    if (roomId != null && currentuser != null) {
      ref.read(socketRepoProvider).leaveChatRoom(
            roomId!,
            currentuser!.id!,
            currentuser!.userName,
          );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(chatViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName ?? 'Chat'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              data: (messageThreads) {
                // Create a flattened list of all chat messages
                final List<FlattenedChatMessage> flattenedMessages = [];

                for (final thread in messageThreads) {
                  if (thread.chats != null) {
                    for (final chat in thread.chats!) {
                      flattenedMessages.add(FlattenedChatMessage(
                        chat: chat,
                        messageModel: thread,
                      ));
                    }
                  }
                }

                if (flattenedMessages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                // Sort messages by timestamp
                flattenedMessages.sort((a, b) => (a.chat.timestamp ?? DateTime.now()).compareTo(b.chat.timestamp ?? DateTime.now()));

                return ListView.builder(
                  itemCount: flattenedMessages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final reverseIndex = flattenedMessages.length - 1 - index;
                    final flatMessage = flattenedMessages[reverseIndex];
                    final bool isMe = flatMessage.chat.sender == currentuser?.id;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: (() {
                        switch (flatMessage.chat.messageType) {
                          case 'text':
                            return CustomChatBubble(
                              message: flatMessage.chat.content,
                              timestamp: _formatTimestamp(
                                flatMessage.chat.timestamp?.millisecondsSinceEpoch ?? 0,
                              ),
                              isSender: isMe,
                              tail: true,
                              bubbleColor: isMe ? Colors.blue : Colors.grey[300]!,
                              textColor: isMe ? Colors.white : Colors.black,
                            );
                          case 'image':
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: flatMessage.chat.mediaData != null
                                        ? Image.memory(
                                            base64Decode(flatMessage.chat.mediaData!.url!.split(',').last),
                                            width: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 100),
                                          )
                                        : Icon(Icons.broken_image, size: 100), // Fallback if mediaData is null
                                  ),
                                  Text(_formatTimestamp(flatMessage.chat.timestamp?.millisecondsSinceEpoch ?? 0)),
                                ],
                              ),
                            );
                          case 'audio':
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.audiotrack, color: isMe ? Colors.white : Colors.black87),
                                      SizedBox(width: 8),
                                      Text('Audio message', style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                                    ],
                                  ),
                                  Text(
                                    _formatTimestamp(flatMessage.chat.timestamp?.millisecondsSinceEpoch ?? 0),
                                    style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          default:
                            return const SizedBox.shrink();
                        }
                      })(),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
          ),
          if (roomId != null)
            Consumer(
              builder: (context, ref, child) {
                final typingUsers = ref.watch(typingUsersProvider(roomId!));
                return typingUsers.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('${typingUsers.length} user(s) typing...'),
                      )
                    : const SizedBox.shrink();
              },
            ),
          const Gap(15),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final fileData = await pickMediaFile();
                  if (fileData != null) {
                    sendFileAndUpdateUI(ref, roomId, currentuser?.id, fileData);
                  }
                },
                icon: Icon(Icons.attach_file),
              ),
              Gap(20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Send a message',
                      hintText: 'Type your message here',
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Cancel any previous timer
                      _typingTimer?.cancel();

                      if (!mounted) return; // Check if widget is still mounted

                      // Handle empty message case immediately
                      if (value.isEmpty && _isCurrentlyTyping) {
                        _isCurrentlyTyping = false;
                        if (roomId != null && currentuser != null && mounted) {
                          ref.read(socketRepoProvider).userTyping({
                            'roomId': roomId,
                            'userId': currentuser!.id,
                            'isTyping': false,
                          });
                        }
                        return;
                      }

                      // Handle non-empty message case
                      if (value.isNotEmpty && (!_isCurrentlyTyping)) {
                        _isCurrentlyTyping = true;
                        if (roomId != null && currentuser != null && mounted) {
                          ref.read(socketRepoProvider).userTyping({
                            'roomId': roomId,
                            'userId': currentuser!.id,
                            'isTyping': true,
                          });
                        }
                      }

                      // Set timer to clear typing status after inactivity
                      _typingTimer = Timer(const Duration(seconds: 2), () {
                        if (mounted && _isCurrentlyTyping) {
                          // Check if widget is still mounted
                          _isCurrentlyTyping = false;
                          if (roomId != null && currentuser != null) {
                            ref.read(socketRepoProvider).userTyping({
                              'roomId': roomId,
                              'userId': currentuser!.id,
                              'isTyping': false,
                            });
                          }
                        }
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_messageController.text.trim().isNotEmpty && roomId != null && currentuser != null) {
                    onSendMessage(_messageController.text.trim());
                    _messageController.clear();

                    // Reset typing indicator when message is sent
                    if (roomId != null && currentuser != null) {
                      ref.read(socketRepoProvider).userTyping({
                        'roomId': roomId,
                        'userId': currentuser!.id,
                        'isTyping': false,
                      });
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return '${dateTime.hour}:${dateTime.minute}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

// Helper class to bundle a chat with its parent message
class FlattenedChatMessage {
  final Chats chat;
  final MessageModel messageModel;

  FlattenedChatMessage({
    required this.chat,
    required this.messageModel,
  });
}
