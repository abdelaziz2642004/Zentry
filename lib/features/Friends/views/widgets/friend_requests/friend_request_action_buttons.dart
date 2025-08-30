import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class FriendRequestActionButtons extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isBlocked;

  const FriendRequestActionButtons({
    super.key,
    required this.onAccept,
    required this.onReject,
    required this.isBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isBlocked ? null : onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isBlocked ? 'Blocked' : 'Accept'),
          ),
        ),
      ],
    );
  }
}
