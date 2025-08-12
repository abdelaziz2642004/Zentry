import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class RoomControl extends StatelessWidget {
  final bool isPrivate;
  final VoidCallback onToggle;

  const RoomControl({
    super.key,
    required this.isPrivate,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isPrivate ? darkSecondaryColor : darkGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(isPrivate ? Icons.lock : Icons.lock_open, color: white),
            const SizedBox(width: 8),
            Text(
              isPrivate ? "Private" : "Public",
              style: const TextStyle(color: white),
            ),
          ],
        ),
      ),
    );
  }
}
