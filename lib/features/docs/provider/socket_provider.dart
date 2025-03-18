import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = io.io("http://192.168.1.9:5762/", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'verbose': true,
    });
    
    socket!
      ..connect()
      ..onConnect((_) => print('Connected to socket server'))
      ..onDisconnect((_) => print('Disconnected from socket server'))
      ..onConnectError((err) => print('Connection error: $err'))
      ..onError((err) => print('Socket error: $err'));
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}