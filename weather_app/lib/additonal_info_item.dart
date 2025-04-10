import 'package:flutter/material.dart';


class AdditonalInfoItem extends StatelessWidget {
  final String name;
  final String value;
  final IconData icon;

  const AdditonalInfoItem({
    super.key,
    required this.name,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}