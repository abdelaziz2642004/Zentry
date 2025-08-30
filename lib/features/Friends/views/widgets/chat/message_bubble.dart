import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/message_bubble_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/message_avatar.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/message_reply_preview.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/message_reactions.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/message_options_dialog.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onDelete;
  final Function(ChatMessage)? onReply;
  final Function(String)? onReact;
  final Function(String)? onViewProfile;
  final bool isBlocked;
  final bool isBlockedByUser;
  final bool isFriend;
  final bool isAnyRequestPending;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onDelete,
    this.onReply,
    this.onReact,
    this.onViewProfile,
    this.isBlocked = false,
    this.isBlockedByUser = false,
    this.isFriend = true,
    this.isAnyRequestPending = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!MessageBubbleUtils.isValidMessage(message)) {
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
          Flexible(child: _buildMessageBubble(context)),
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

  Widget _buildMessageBubble(BuildContext context) {
    final canInteract = MessageBubbleUtils.canInteractWithMessage(
      isFriend: isFriend,
      isBlocked: isBlocked,
      isBlockedByUser: isBlockedByUser,
      isAnyRequestPending: isAnyRequestPending,
    );

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MessageBubbleUtils.getMaxMessageWidth(context),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: MessageBubbleUtils.getMessageBubbleColor(isMe),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reply preview
            MessageReplyPreview(message: message, isMe: isMe),

            // Sender name (only for other user's messages)
            if (!isMe) ...[
              Text(
                message.senderName,
                style: TextStyle(
                  color: MessageBubbleUtils.getSenderNameColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
            ],

            // Message content
            Text(
              message.content,
              style: TextStyle(
                color: MessageBubbleUtils.getMessageTextColor(isMe),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),

            // Reactions
            MessageReactions(
              message: message,
              isMe: isMe,
              canInteract: canInteract,
              onReact: onReact,
            ),

            // Timestamp
            Text(
              MessageBubbleUtils.formatTimestamp(message.timestamp),
              style: TextStyle(
                color: MessageBubbleUtils.getTimestampColor(isMe),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    final canInteract = MessageBubbleUtils.canInteractWithMessage(
      isFriend: isFriend,
      isBlocked: isBlocked,
      isBlockedByUser: isBlockedByUser,
      isAnyRequestPending: isAnyRequestPending,
    );

    showModalBottomSheet(
      context: context,
      builder:
          (context) => MessageOptionsDialog(
            message: message,
            isMe: isMe,
            canInteract: canInteract,
            onDelete: onDelete,
            onReply: onReply,
            onReact: onReact,
          ),
    );
  }
}
