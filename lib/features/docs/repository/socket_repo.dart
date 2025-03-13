import 'package:socket_io_client/socket_io_client.dart';
import 'package:zenzen/features/docs/provider/socket_provider.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  // Join a document room
  void joinDocument(String documentId, String userId) {
    _socketClient.emit('join-document', {
      'documentId': documentId,
      'userId': userId,
    });
  }

  // Leave a document room
  void leaveDocument(String documentId, String userId) {
    _socketClient.emit('leave-document', {
      'documentId': documentId,
      'userId': userId,
    });
  }

  // Send document changes to other users
  void sendDocumentChanges(Map<String, dynamic> content,) {
    _socketClient.emit('docs', content);
  }

  // Save document to database
  void autoSave(Map<String, dynamic> data) {
    _socketClient.emit('save', data);
  }

  // Listen for document changes from other users
  void onDocumentChange(Function(String, String) callback) {
    _socketClient.on('document-change', (data) {
      callback(data['content'], data['timestamp']);
    });
  }

  // Listen for initial document load
  void onLoadDocument(Function(dynamic) callback) {
    _socketClient.on('load-document', (data) {
      callback(data);
    });
  }

  // Listen for users count updates
  void onUsersCountUpdate(Function(String, int) callback) {
    _socketClient.on('users-count', (data) {
      callback(data['documentId'], data['count']);
    });
  }

  // Disconnect socket
  void disconnect() {
    _socketClient.disconnect();
  }
}
