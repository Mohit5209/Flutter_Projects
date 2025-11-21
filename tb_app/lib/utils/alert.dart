import 'package:flutter/material.dart';

void showCustomPopup({
  required BuildContext context,
  required String title,
  required String content,
  String buttonText = "OK",
  VoidCallback? onPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF171A1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE8ECF2),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(color: Color(0xFFE8ECF2)),
        ),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Color(0xFF7B4DFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
