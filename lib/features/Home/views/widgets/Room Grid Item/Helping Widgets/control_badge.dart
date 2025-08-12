
import 'package:flutter/material.dart';

class ControlBadge extends StatelessWidget {
  const ControlBadge({
    super.key,
    required this.isPublic,
  });

  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (isPublic ? Colors.green : Colors.grey).withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPublic
                  ? Icons.lock_open_rounded
                  : Icons.lock_outline_rounded,
              size: 12,
              color: isPublic ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              isPublic ? "Public" : "Private",
              style: TextStyle(
                fontSize: 10,
                color: isPublic ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

