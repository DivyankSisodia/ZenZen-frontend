import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/data/sockets/socket_repo.dart';

import '../../../../data/local/hive_models/local_user_model.dart';
import '../../../../data/local/provider/hive_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  final String? chatId;
  final String? chatName;
  final String? chatImage;
  const ChatListScreen({super.key, this.chatId, this.chatName, this.chatImage});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  SocketRepository socketRepository = SocketRepository();
  LocalUser? currentuser;
  String? roomId;

  @override
  void initState() {
    super.initState();

    // get current user
    getCurrentUser();
  }

  void getCurrentUser() async {
    final hiveService = ref.read(userDataProvider);
    final user = hiveService.userBox.get('currentUser');
    if (mounted) {
      setState(() {
        currentuser = user;
        if (widget.chatId != null && currentuser != null) {
          List<String> ids = [widget.chatId!, currentuser!.id!];
          ids.sort();
          roomId = ids.join('-');
          print('roomId: $roomId');
          joinChat(); // Ensure joinChat is called after roomId is set
        }
      });
    }
  }

  void joinChat() {
    if (roomId == null || currentuser == null) {
      return;
    }

    if (socketRepository.socketClient.connected) {
      socketRepository.joinChatRoom({
        'roomId': roomId,
        'userId': currentuser!.id,
      });
    } else {
      socketRepository.socketClient.connect();

      socketRepository.socketClient.once('connect', (_) {
        if (currentuser != null) {
          socketRepository.joinChatRoom({
            'roomId': roomId,
            'userId': currentuser!.id,
          });
        }
      });
    }
  }

  // listen messages & auto scrolling
  void setUpSocketListeners() {
    socketRepository.onChatMessage((data) {
      // Handle incoming messages
    });
  }

  @override
  void dispose() {
    super.dispose();
    socketRepository.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Chat Item $index'),
                  subtitle: Text('Last message from Chat Item $index'),
                  onTap: () {
                    // Navigate to chat detail screen
                  },
                );
              },
            ),
          ),
          const Gap(15),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Send a message',
                      hintText: 'Type your message here',
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle search logic
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  // Handle send message action
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
