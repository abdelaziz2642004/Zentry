import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/room_invitation_utils.dart';

class RoomInfoDisplay extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const RoomInfoDisplay({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: RoomInvitationUtils.getRoomInfoBackgroundColor(isMe),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            RoomInvitationUtils.getRoomInfoIcon(),
            color: RoomInvitationUtils.getRoomInfoTextColor(isMe),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Room: ${RoomInvitationUtils.getRoomIdentifier(message)}',
              style: TextStyle(
                color: RoomInvitationUtils.getRoomInfoTextColor(isMe),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
