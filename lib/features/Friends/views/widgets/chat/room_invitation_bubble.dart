import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/room_invitation_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/message_bubble_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/message_avatar.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/room_invitation_header.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/room_info_display.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/join_room_button.dart';

class RoomInvitationBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback onJoinRoom;
  final Function(String)? onViewProfile;

  const RoomInvitationBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onJoinRoom,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (!RoomInvitationUtils.isValidRoomInvitation(message)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            MessageAvatar(
              message: message,
              isMe: isMe,
              onViewProfile: onViewProfile,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: _buildInvitationBubble(context)),
          if (isMe) ...[
            const SizedBox(width: 8),
            MessageAvatar(
              message: message,
              isMe: isMe,
              onViewProfile: onViewProfile,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvitationBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: RoomInvitationUtils.getMaxInvitationWidth(context),
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RoomInvitationUtils.getInvitationBubbleColor(isMe),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RoomInvitationUtils.getInvitationBorderColor(isMe),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with sender name and invitation title
          RoomInvitationHeader(message: message, isMe: isMe),
          const SizedBox(height: 8),

          // Message content
          Text(
            message.content,
            style: TextStyle(
              color: RoomInvitationUtils.getInvitationContentColor(isMe),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          // Room info display
          RoomInfoDisplay(message: message, isMe: isMe),
          const SizedBox(height: 12),

          // Join room button
          JoinRoomButton(isMe: isMe, onJoinRoom: onJoinRoom),
          const SizedBox(height: 4),

          // Timestamp
          Text(
            MessageBubbleUtils.formatTimestamp(message.timestamp),
            style: TextStyle(
              color: RoomInvitationUtils.getTimestampColor(isMe),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
