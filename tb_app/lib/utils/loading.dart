import 'package:flutter/material.dart';

Future<void> showLoadingPopup({
  required BuildContext context,
  required Future<void> Function() asyncFunction,
  String loadingText = "Loading...",
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF171A1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF7B4DFF)),
            ),
            const SizedBox(height: 20),
            Text(
              loadingText,
              style: const TextStyle(color: Color(0xFFE8ECF2), fontSize: 16),
            ),
          ],
        ),
      );
    },
  );

  await asyncFunction();

  if (Navigator.canPop(context)) {
    Navigator.of(context).pop();
  }
}
