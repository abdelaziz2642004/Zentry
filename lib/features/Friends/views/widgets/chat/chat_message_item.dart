import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/chat_messages_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/message_bubble.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/room_invitation_bubble.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final bool isBlocked;
  final bool isBlockedByUser;
  final bool isFriend;
  final bool isAnyRequestPending;
  final VoidCallback? onDelete;
  final Function(ChatMessage?)? onReplyStateChanged;
  final Function(String)? onReact;
  final VoidCallback? onJoinRoom;
  final Function(String)? onViewProfile;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.isBlocked,
    required this.isBlockedByUser,
    required this.isFriend,
    required this.isAnyRequestPending,
    this.onDelete,
    this.onReplyStateChanged,
    this.onReact,
    this.onJoinRoom,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = ChatMessagesUtils.isMessageFromMe(message);
    final messageType = ChatMessagesUtils.getMessageBubbleType(message);

    if (messageType == MessageBubbleType.roomInvitation) {
      return RoomInvitationBubble(
        message: message,
        isMe: isMe,
        onJoinRoom: onJoinRoom ?? () => _handleJoinRoom(context),
        onViewProfile:
            onViewProfile ?? (userId) => _handleViewProfile(context, userId),
      );
    } else {
      return MessageBubble(
        message: message,
        isMe: isMe,
        isBlocked: isBlocked,
        isBlockedByUser: isBlockedByUser,
        isFriend: isFriend,
        isAnyRequestPending: isAnyRequestPending,
        onDelete: onDelete,
        onReply: onReplyStateChanged,
        onReact: onReact,
        onViewProfile:
            onViewProfile ?? (userId) => _handleViewProfile(context, userId),
      );
    }
  }

  void _handleJoinRoom(BuildContext context) {
    // This will be handled by the parent widget
    if (onJoinRoom != null) {
      onJoinRoom!();
    }
  }

  void _handleViewProfile(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => ProfilePopupDialog(userId: userId),
    );
  }
}
