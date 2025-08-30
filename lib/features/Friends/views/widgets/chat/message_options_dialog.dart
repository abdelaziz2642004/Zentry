import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/message_bubble_utils.dart';

class MessageOptionsDialog extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool canInteract;
  final VoidCallback? onDelete;
  final Function(ChatMessage)? onReply;
  final Function(String)? onReact;

  const MessageOptionsDialog({
    super.key,
    required this.message,
    required this.isMe,
    required this.canInteract,
    this.onDelete,
    this.onReply,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            enabled: canInteract,
            onTap:
                canInteract
                    ? () {
                      Navigator.pop(context);
                      onReply?.call(message);
                    }
                    : null,
          ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions),
            title: const Text('React'),
            enabled: canInteract,
            onTap:
                canInteract
                    ? () {
                      Navigator.pop(context);
                      _showReactionPicker(context);
                    }
                    : null,
          ),
          if (isMe) ...[
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    final emojis = MessageBubbleUtils.getAvailableEmojis();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Reaction'),
            content: Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  emojis
                      .map(
                        (emoji) => GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            onReact?.call(emoji);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
