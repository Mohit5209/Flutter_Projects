import 'package:flutter/material.dart';

Future<String?> showSelectionDialog({
  required BuildContext context,
  String initial = 'Group',
  String title = 'Select mode',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      String? value = initial;
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
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  activeColor: const Color(0xFF7B4DFF),
                  title: const Text(
                    'Group',
                    style: TextStyle(color: Color(0xFFE8ECF2)),
                  ),
                  value: 'Group',
                  groupValue: value,
                  onChanged: (v) => setState(() => value = v),
                ),
                RadioListTile<String>(
                  activeColor: const Color(0xFF7B4DFF),
                  title: const Text(
                    'Private',
                    style: TextStyle(color: Color(0xFFE8ECF2)),
                  ),
                  value: 'Private',
                  groupValue: value,
                  onChanged: (v) => setState(() => value = v),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF7B4DFF)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(value ?? initial),
            child: const Text(
              'Continue',
              style: TextStyle(color: Color(0xFF7B4DFF)),
            ),
          ),
        ],
      );
    },
  );
}
