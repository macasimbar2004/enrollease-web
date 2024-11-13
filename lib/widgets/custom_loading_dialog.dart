import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    barrierDismissible:
        false, // Prevent dismissing the dialog by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title), // Display the title of the dialog
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
          ],
        ),
        actions: const [], // No actions/buttons in this dialog
      );
    },
  );
}
