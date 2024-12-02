import 'package:flutter/material.dart';

void showDynamicDialog({
  required BuildContext context,
  required Widget title,
  required Widget contentWidgets,
  required List<Widget> actionButtons,
  GlobalKey<FormState>? formKey,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        width: 1000,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Dialog Title
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel)),
                ),

                DefaultTextStyle(
                  style: const TextStyle(fontSize: 24, color: Colors.black),
                  child: title,
                ),

                const SizedBox(height: 20),

                // Dynamic Content
                Expanded(
                  child: SingleChildScrollView(
                    child: contentWidgets,
                  ),
                ), // Spread operator to add content widgets

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actionButtons,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
