import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true); // Confirm action
            },
            style: TextButton.styleFrom(backgroundColor: cancelText.isNotEmpty ? Colors.green : Colors.blue),
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
          if (cancelText.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false); // Cancel action
              },
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: Text(cancelText, style: const TextStyle(color: Colors.white)),
            ),
        ],
      );
    },
  );
}
