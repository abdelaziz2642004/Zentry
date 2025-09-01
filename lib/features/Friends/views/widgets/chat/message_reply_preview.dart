import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/message_bubble_utils.dart';

class MessageReplyPreview extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageReplyPreview({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (!MessageBubbleUtils.hasReply(message)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: MessageBubbleUtils.getReplyPreviewBackgroundColor(isMe),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MessageBubbleUtils.getReplyPreviewText(message.replyToSenderName),
            style: TextStyle(
              color: MessageBubbleUtils.getReplyPreviewTextColor(isMe),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.replyToMessageContent ?? '',
            style: TextStyle(
              color: MessageBubbleUtils.getReplyPreviewContentColor(isMe),
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
