import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/room_invitation_utils.dart';

class RoomInvitationHeader extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const RoomInvitationHeader({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender name (only for other user's messages)
        if (!isMe) ...[
          Text(
            message.senderName,
            style: TextStyle(
              color: RoomInvitationUtils.getSenderNameColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
        ],

        // Invitation title with icon
        Row(
          children: [
            Icon(
              RoomInvitationUtils.getInvitationIcon(),
              color: RoomInvitationUtils.getInvitationIconColor(isMe),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              RoomInvitationUtils.getInvitationTitle(),
              style: TextStyle(
                color: RoomInvitationUtils.getInvitationTitleColor(isMe),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
