import 'package:flutter/material.dart';

class CustomSuccessWidget {
  // Show error SnackBar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[400],
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 10,
            ),
            Text(message),
            const Icon(Icons.check, color: Colors.white),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
