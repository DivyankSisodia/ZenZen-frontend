import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

class CustomToast {
  void showToast(String title, BuildContext context) {
    DelightToastBar(
      snackbarDuration: const Duration(seconds: 3),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 500),
      autoDismiss: true,
      builder: (context) => ToastCard(
        leading: Icon(Icons.error, size: 28, color: Colors.red),
        title: Text(title),
        trailing: Icon(Icons.close),
      ),
    ).show(context);
  }
}
