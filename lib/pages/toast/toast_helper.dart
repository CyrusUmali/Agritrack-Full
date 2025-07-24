import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void showToast({
    required BuildContext context,
    required String message,
    required ToastificationType type,
    Duration duration = const Duration(seconds: 5),
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(
        message,
        overflow: TextOverflow.visible,
        maxLines: 3,
      ),
      autoCloseDuration: duration,
    );
  }

  static void showSuccessToast(String message, BuildContext context) {
    showToast(
      context: context,
      message: message,
      type: ToastificationType.success,
    );
  }

  static void showErrorToast(String message, BuildContext context) {
    showToast(
      context: context,
      message: message,
      type: ToastificationType.error,
    );
  }

  // You can add more specific methods for other toast types if needed
  static void showInfoToast(String message, BuildContext context) {
    showToast(
      context: context,
      message: message,
      type: ToastificationType.info,
    );
  }

  static void showWarningToast(String message, BuildContext context) {
    showToast(
      context: context,
      message: message,
      type: ToastificationType.warning,
    );
  }
}
