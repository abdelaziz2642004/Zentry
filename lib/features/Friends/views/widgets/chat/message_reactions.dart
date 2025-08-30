import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/message_bubble_utils.dart';

class MessageReactions extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool canInteract;
  final Function(String)? onReact;

  const MessageReactions({
    super.key,
    required this.message,
    required this.isMe,
    required this.canInteract,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    if (!MessageBubbleUtils.hasReactions(message)) {
      return const SizedBox.shrink();
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Wrap(
      spacing: 4,
      children:
          message.reactions!.entries.map((entry) {
            final emoji = entry.key;
            final userCount = entry.value.length;
            final hasReacted = entry.value.contains(currentUserId);

            return GestureDetector(
              onTap: canInteract ? () => onReact?.call(emoji) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: MessageBubbleUtils.getReactionBackgroundColor(
                    hasReacted: hasReacted,
                    isMe: isMe,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      MessageBubbleUtils.getReactionBorderColor(
                                hasReacted: hasReacted,
                                isMe: isMe,
                              ) !=
                              null
                          ? Border.all(
                            color:
                                MessageBubbleUtils.getReactionBorderColor(
                                  hasReacted: hasReacted,
                                  isMe: isMe,
                                )!,
                            width: 1,
                          )
                          : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    if (userCount > 1) ...[
                      const SizedBox(width: 2),
                      Text(
                        userCount.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: MessageBubbleUtils.getReactionTextColor(
                            hasReacted: hasReacted,
                            isMe: isMe,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
