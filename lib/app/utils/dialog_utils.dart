import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  String? message, // <-- tambahkan parameter message
  Widget? content, // <-- tetap bisa custom content
  String cancelText = "Batal",
  String confirmText = "OK",
  VoidCallback? onConfirm,
  Color? iconColor,
  IconData? icon,
  bool showConfirmButton = true,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.25 < 320
              ? 320
              : MediaQuery.of(context).size.width * 0.25,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).primaryColor,
                  size: 48,
                ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: iconColor ?? Theme.of(context).primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (content != null)
                content
              else if (message != null)
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor:
                            iconColor ?? Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(cancelText),
                    ),
                  ),
                  if (showConfirmButton) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              iconColor ?? Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (onConfirm != null) onConfirm();
                        },
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
