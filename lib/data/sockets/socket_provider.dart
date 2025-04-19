import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? socket;
  static SocketClient? _instance;
  bool _isConnecting = false;

  SocketClient._internal() {
    socket = io.io("http://localhost:5762/", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
      'verbose': true,
    });

    socket!
      ..onConnect((_) {
        print('Connected to socket server');
        _isConnecting = false;
      })
      ..onDisconnect((_) => print('Disconnected from socket server'))
      ..onConnectError((err) {
        print('Connection error: $err');
        _isConnecting = false;
      })
      ..onError((err) => print('Socket error: $err'))
      ..onReconnect((_) => print('Reconnected to socket server'))
      ..onReconnectAttempt((attempt) => print('Reconnect attempt: $attempt'));
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }

  void connect() {
    if (socket != null && !socket!.connected && !_isConnecting) {
      _isConnecting = true;
      socket!.connect();
    }
  }

  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }
  }

  void dispose() {
    socket?.dispose();
    socket = null;
    _instance = null;
  }
}