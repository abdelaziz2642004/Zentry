import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class GroupActionButtons extends StatelessWidget {
  final StudyGroup group;
  final bool isUserMember;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onChat;

  const GroupActionButtons({
    super.key,
    required this.group,
    required this.isUserMember,
    this.onJoin,
    this.onLeave,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isUserMember) ...[
          // User is a member - show chat and leave options
          if (onChat != null) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onChat,
                icon: const Icon(Icons.chat, size: 16),
                label: const Text('Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (onLeave != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onLeave,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Leave'),
              ),
            ),
          ],
        ] else ...[
          // User is not a member - show join option
          if (onJoin != null) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: group.canJoin ? onJoin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  group.isFull
                      ? 'Full'
                      : group.isPrivate
                      ? 'Join Private'
                      : 'Join',
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
