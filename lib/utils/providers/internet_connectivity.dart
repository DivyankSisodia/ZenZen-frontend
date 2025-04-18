import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityStatusNotifier extends StateNotifier<bool> {
  ConnectivityStatusNotifier() : super(false) {
    _monitorInternetConnection();
  }

  void _monitorInternetConnection() {
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      state = (status == InternetStatus.connected);
    });
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityStatusNotifier, bool>((ref) {
  return ConnectivityStatusNotifier();
});
