import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/internet_connectivity.dart';

class GlobalConnectivityWidget extends ConsumerWidget {
  const GlobalConnectivityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityProvider);

    return !isConnected
        ? Container(
            color: Colors.red,
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "No Internet Connection",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
