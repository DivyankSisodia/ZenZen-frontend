import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/data/sockets/socket_repo.dart';
import 'package:zenzen/features/dashboard/chat/model/message_model.dart';

import '../../../../data/local/hive_models/local_user_model.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../model/chat_model.dart';
import '../provider/chatMessage_provider.dart';
import '../provider/chat_message_provider.dart';
import '../provider/typing_provider.dart';

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


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(chatMessageRepositoryProvider).getChatMessages(widget.id!);
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

      // Create a MessageModel from the received data
      final MessageModel message = MessageModel(
        chatRoom: ChatRoom(roomId: data['roomId']),
        roomId: data['roomId'],
        senderId: data['userId'],
        content: data['message'],
        messageType: data['type'],
        timestamp: data['timestamp'],
      );

      // Update state with the new message using the provider
      if (roomId != null) {
        ref.read(chatMessagesProvider(roomId!).notifier).addMessage(message);
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
        'userId': currentuser!.id, // Your server handles either userId or sender
        'message': messageText,
        'type': 'text', // Your server handles either type or messageType
      };

      // Send via socket
      ref.read(socketRepoProvider).sendChatMessage(messageData);

      // Create local message model for our UI
      final newMessage = MessageModel(
        chatRoom: ChatRoom(roomId: roomId!),
        roomId: roomId!,
        senderId: currentuser!.id!,
        content: messageText,
        messageType: 'text',
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );

      // Add to our local state
      ref.read(chatMessagesProvider(roomId!).notifier).addMessage(newMessage);
    }
  }

  void listenForTypingIndicators() {
      ref.read(socketRepoProvider).onUserTyping((data) {
        final userId = data['userId'] as String;
        final isTyping = data['isTyping'] as bool;

        if (roomId != null) {
          ref.read(typingUsersProvider(roomId!).notifier).setTyping(userId, isTyping);
        }
      });
    }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    if (roomId != null) {
      ref.read(socketRepoProvider).leaveChatRoom(
        roomId ?? '',
        currentuser?.id ?? '',
        currentuser?.userName ?? '', // Assuming 'username' is the correct property
      );
    }
    // ref.read(socketDisconnetProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    // If the room ID exists, watch the message list
    final messages = roomId != null ? ref.watch(chatMessagesProvider(roomId!)) : <MessageModel>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName ?? 'Chat'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final bool isMe = message.senderId == currentuser?.id;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message.timestamp!.millisecondsSinceEpoch),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                      // Implement user typing indicator
                      if (roomId != null && currentuser != null) {
                        ref.read(socketRepoProvider).userTyping({
                          'roomId': roomId,
                          'userId': currentuser!.id,
                          'isTyping': value.isNotEmpty,
                        });
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_messageController.text.trim().isNotEmpty && roomId != null && currentuser != null) {
                    final newMsg = MessageModel(
                      chatRoom: ChatRoom(roomId: roomId!),
                      roomId: roomId!,
                      senderId: currentuser!.id!,
                      content: _messageController.text.trim(),
                      messageType: 'text',
                    );

                    onSendMessage(_messageController.text.trim());
                    _messageController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper method to format timestamp
String _formatTimestamp(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
