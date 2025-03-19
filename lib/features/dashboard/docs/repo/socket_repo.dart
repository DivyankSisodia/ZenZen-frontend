import 'package:socket_io_client/socket_io_client.dart';
import 'package:zenzen/features/dashboard/docs/provider/socket_provider.dart';

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
  void onDocumentChange(Function(Map<String, dynamic>) func) {
    print('Listening for document changes');
    _socketClient.on('document-change', (data) {
      func(data);
    });
  }

  // Listen for users count updates
  void onUsersCountUpdate(Function(String, int) callback) {
    _socketClient.on('users-count', (data) {
      callback(data['documentId'], data['count']);
    });
  }

  void removeDocumentChangeListener() {
    _socketClient.off('document-change');
  }

  // Disconnect socket
  void disconnect() {
    _socketClient.disconnect();
  }
}
