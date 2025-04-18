import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/data/sockets/socket_repo.dart';
import 'package:zenzen/features/dashboard/chat/model/message_model.dart';

import '../../../../data/local/hive_models/local_user_model.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../provider/typing_provider.dart';
import '../view-model/chat_viewmodel.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final String? id;
  final String? chatRoomId;
  final String? chatName;
  final String? chatImage;
  const ChatListScreen(
      {super.key, this.chatRoomId, this.chatName, this.chatImage, this.id});

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

  void onChangedMessages() {
    ref.read(socketRepoProvider).onChatMessage((data) {
      print('New message received: $data');

      final chat = Chats(
        sender: data['sender'] as String,
        content: data['message'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
        messageType: data['messageType'] as String?,
        mediaData: null,
        isDeleted: false,
        isEdited: false,
        isSystemMessage: false,
      );
      print('Created Chats: ${chat.toJson()}'); // Log the Chats object

      final MessageModel message = MessageModel(
        id: null,
        roomId: data['roomId'] as String?,
        chatRoom: null,
        chats: [chat],
        createdAt: DateTime.parse(data['timestamp'] as String),
        updatedAt: DateTime.parse(data['timestamp'] as String),
      );

      if (roomId != null) {
        ref.read(chatViewModelProvider.notifier).addMessage(message);
        // Scroll to bottom
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (_scrollController.hasClients) {
        //     _scrollController.animateTo(
        //       _scrollController.position.maxScrollExtent,
        //       duration: Duration(milliseconds: 300),
        //       curve: Curves.easeOut,
        //     );
        //   }
        // });
      }
    });
  }

  void onSendMessage(String messageText) {
    if (roomId != null && currentuser != null && messageText.isNotEmpty) {
      // Get current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Create the message object to send
      final messageData = {
        'roomId': roomId!,
        'userId':
            currentuser!.id, // Your server handles either userId or sender
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
    }
  }

  void listenForTypingIndicators() {
    ref.read(socketRepoProvider).onUserTyping((data) {
      final userId = data['userId'] as String;
      final roomId = data['roomId'] as String;
      // Assume typing is true when the event is received
      final isTyping = data['isTyping'] as bool? ?? true;

      ref
          .read(typingUsersProvider(roomId).notifier)
          .setTyping(userId, roomId, isTyping);
    });
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
                flattenedMessages.sort((a, b) =>
                    (a.chat.timestamp ?? DateTime.now())
                        .compareTo(b.chat.timestamp ?? DateTime.now()));

                return ListView.builder(
                  itemCount: flattenedMessages.length,
                  itemBuilder: (context, index) {
                    final flatMessage = flattenedMessages[index];
                    final bool isMe =
                        flatMessage.chat.sender == currentuser?.id;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flatMessage.chat.content,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(flatMessage
                                  .chat.timestamp!.millisecondsSinceEpoch),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
            ),
          ),
          const Gap(8),
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
                  if (_messageController.text.trim().isNotEmpty &&
                      roomId != null &&
                      currentuser != null) {
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
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
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
