import 'package:flutter/material.dart';

class WorkBreakView extends StatelessWidget {
  const WorkBreakView({
    super.key,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final String time;
  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Text(time, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
