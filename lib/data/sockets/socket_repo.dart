
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:zenzen/data/sockets/socket_provider.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  // Join a document room
  void joinDocument(Map<String, dynamic> data) {
    print('Joining document room');
    _socketClient.emit('join-document', data);
  }

  // Leave a document room
  void leaveDocument(Map<String, dynamic> data) {
    _socketClient.emit('leave-document', data);
  }

  // Send document changes to other users
  void sendDocumentChanges(
    Map<String, dynamic> content,
  ) {
    print('Sending document changes, ${content['documentId']}');
    _socketClient.emit('docs', content);
  }

  // Save document to database
  void autoSave(Map<String, dynamic> data) {
    _socketClient.emit('save', data);
  }

  // Listen for document changes from other users
  void onDocumentChange(void Function(Map<String, dynamic>) func) {
    print('Listening for document changes');
    _socketClient.on('document-change', (data) {
      func(data as Map<String, dynamic>);
    });
  }

  // Listen for users count updates
  void onUsersCountUpdate(void Function(String, List, int) callback) {
    _socketClient.on('users-list', (data) {
      callback(data['documentId'] as String, data['users'], data['count'] as int);
    });
  }

  void removeDocumentChangeListener() {
    _socketClient.off('document-change');
  }

  // From here onwards we have events
  // for file-transfer.

  void sendFileChunk(Map<String, dynamic> data) {
    _socketClient.emit('file_chunk', data);
  }

  void sendFileTransferComplete(Map<String, dynamic> data) {
    _socketClient.emit('file_transfer_complete', data);
  }

  void sendFileTransferCancel(Map<String, dynamic> data) {
    _socketClient.emit('file_transfer_cancel', data);
  }

  void onFileChunk(void Function(Map<String, dynamic>) handler) {
    _socketClient.on('file_chunk', (data) {
      handler(data as Map<String, dynamic>);
    });
  }

  void onFileTransferComplete(void Function(Map<String, dynamic>) handler) {
    _socketClient.on('file_transfer_complete', (data) {
      handler(data as Map<String, dynamic>);
    });
  }

  void onFileTransferCancel(void Function(Map<String, dynamic>) handler) {
    _socketClient.on('file_transfer_cancel', (data) {
      handler(data as Map<String, dynamic>);
    });
  }

  void onUserJoined(void Function(String) handler) {
    _socketClient.on('user_joined', (data) {
      handler(data['userId'] as String);
    });
  }

  void createFileRoom({
    required void Function(String roomId) onSuccess,
    required void Function(String error) onError,
  }) {
    _socketClient.emitWithAck('create_file_room', {}, ack: (data) {
      if (data['success'] as bool) {
        final roomId = data['roomId'] as String;
        onSuccess(roomId);
      } else {
        final error = data['error'] as String;
        onError(error);
      }
    });
  }

  void joinFileRoom(String roomId, {required void Function() onSuccess, required void Function(String) onError}) {
    _socketClient.emitWithAck('join_room', roomId, ack: (data) {
      if (data['success'] as bool) {
        onSuccess();
      } else {
        onError(data['error'] as String);
      }
    });
  }

  void leaveFileRoom(String roomId) {
    print('Leaving room $roomId');
    _socketClient.emit('leave_file_room', roomId);
    print('Left room $roomId');
  }

  // Chat Room socket evenets

  // SocketRepository() {
  //   // Listen for dashboardData event from the server
  //   _socketClient.on('dashboardData', (data) {
  //     if (data['success'] == true) {
  //       print('Dashboard data received: ${data['data']}');
  //       _dashboardDataController.add(data['data']); // data['data'] is the List
  //     } else {
  //       _dashboardDataController.addError(Exception(data['error']));
  //     }
  //   });
  // }

  // Method to request dashboard data
  void getDashboardData(String userId) {
    _socketClient.emit('getDashboardData', {'userId': userId});
  }

  void joinChatRoom(Map<String, dynamic> data) {
    print('Joining chat room');
    _socketClient.emit('joinChat', data);
  }

  void sendChatMessage(Map<String, dynamic> data) {
    print('Sending chat message: $data');
    _socketClient.emit('sendMessage', data);
  }

  void userTyping(Map<String, dynamic> data) {
    print('User typing: $data');
    _socketClient.emit('typing', data);
  }

  void onChatMessage(void Function(Map<String, dynamic>) func) {
    print('Listening for chat messages');
    _socketClient.on('receiveMessage', (data) {
      func(data as Map<String, dynamic>);
    });
  }

  void onUserTyping(void Function(Map<String, dynamic>) func) {
    print('Listening for user typing');
    _socketClient.on('userTyping', (data) {
      func(data as Map<String, dynamic>);
    });
  }

  void leaveChatRoom(String roomId,String userId, String userName) {
    print('Leaving chat room');
    _socketClient.emit('leaveChat', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
    });
    print('Left chat room');
  }

  // Remove listeners
  void removeChatMessageListener() {
    _socketClient.off('receiveMessage');
  }

  void removeUserTypingListener() {
    _socketClient.off('userTyping');
  }

  void removeFileChunkListener() {
    _socketClient.off('file_chunk');
  }

  void removeFileTransferCompleteListener() {
    _socketClient.off('file_transfer_complete');
  }

  void removeFileTransferCancelListener() {
    _socketClient.off('file_transfer_cancel');
  }

  void removeUserJoinedListener() {
    _socketClient.off('user_joined');
  }

  void removeUsersCountListener() {
    _socketClient.off('users-list');
  }

  void disconnect() {
    _socketClient.disconnect();
    print('Disconnected from socket server');
  }
}

final socketRepoProvider = Provider<SocketRepository>((ref) {
  return SocketRepository();
});