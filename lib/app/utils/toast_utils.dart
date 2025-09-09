import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showAppToast({
  required BuildContext context,
  required ToastificationType type,
  required String title,
  String? description,
  ToastificationStyle style = ToastificationStyle.fillColored,
  Duration duration = const Duration(seconds: 3),
  Alignment alignment = Alignment.topCenter,
  List<BoxShadow>? boxShadow,
  bool dragToClose = true,
}) {
  toastification.show(
    context: context,
    type: type,
    style: style,
    title: Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    description: description != null
        ? Text(
            description,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          )
        : null,
    alignment: alignment,
    autoCloseDuration: duration,
    boxShadow: boxShadow,
    dragToClose: dragToClose,
  );
}
