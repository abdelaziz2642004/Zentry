import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Abstract base class for all message bubbles in the app
/// This eliminates code duplication across different chat types
abstract class BaseMessageBubble<T> extends StatelessWidget {
  final T message;
  final bool isMyMessage;
  final VoidCallback? onDelete;
  final Function(T)? onReply;
  final Function(String)? onReact;
  final Function(String)? onViewProfile;

  const BaseMessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.onDelete,
    this.onReply,
    this.onReact,
    this.onViewProfile,
  });

  /// Check if this is a system message
  bool get isSystemMessage;

  /// Get the message content
  String get messageContent;

  /// Get the sender name
  String get senderName;

  /// Get the sender ID
  String get senderId;

  /// Get the message timestamp
  DateTime get timestamp;

  /// Get the reply information
  ReplyInfo? get replyInfo;

  /// Get the reactions map
  Map<String, List<String>>? get reactions;

  /// Get the message bubble color
  Color getMessageBubbleColor() {
    return isMyMessage ? Colors.blue[500]! : Colors.grey[100]!;
  }

  /// Get the message text color
  Color getMessageTextColor() {
    return isMyMessage ? Colors.white : Colors.grey[800]!;
  }

  /// Get the timestamp color
  Color getTimestampColor() {
    return isMyMessage ? Colors.white70 : Colors.grey[500]!;
  }

  /// Get the sender name color
  Color getSenderNameColor() {
    return Colors.grey[600]!;
  }

  /// Get the avatar background color
  Color getAvatarBackgroundColor() {
    return isMyMessage ? Colors.blue[400]! : Colors.grey[400]!;
  }

  /// Get the max width for the message bubble
  double getMaxMessageWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    if (isSystemMessage) {
      return _buildSystemMessage();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[_buildAvatar(), const SizedBox(width: 8)],
          Flexible(child: _buildMessageBubble(context)),
          if (isMyMessage) ...[const SizedBox(width: 8), _buildAvatar()],
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            messageContent,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        constraints: BoxConstraints(maxWidth: getMaxMessageWidth(context)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: getMessageBubbleColor(),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reply preview
            if (replyInfo != null) ...[
              _buildReplyPreview(),
              const SizedBox(height: 8),
            ],

            // Sender name (only for other user's messages)
            if (!isMyMessage) ...[
              Text(
                senderName,
                style: TextStyle(
                  color: getSenderNameColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
            ],

            // Message content
            Text(
              messageContent,
              style: TextStyle(color: getMessageTextColor(), fontSize: 14),
            ),
            const SizedBox(height: 4),

            // Reactions
            if (reactions != null && reactions!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildReactions(),
            ],

            // Timestamp
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(color: getTimestampColor(), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMyMessage ? Colors.white.withOpacity(0.2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replying to ${replyInfo!.replyToSenderName ?? 'Unknown'}',
            style: TextStyle(
              color: isMyMessage ? Colors.white70 : Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyInfo!.replyToMessageContent ?? '',
            style: TextStyle(
              color: isMyMessage ? Colors.white70 : Colors.grey[700],
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReactions() {
    return Wrap(
      spacing: 4,
      children:
          reactions!.entries.map((entry) {
            final emoji = entry.key;
            final userCount = entry.value.length;
            final hasReacted = entry.value.contains(getCurrentUserId());

            return GestureDetector(
              onTap:
                  canInteractWithMessage() ? () => onReact?.call(emoji) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getReactionBackgroundColor(hasReacted),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      _getReactionBorderColor(hasReacted) != null
                          ? Border.all(
                            color: _getReactionBorderColor(hasReacted)!,
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
                          color: _getReactionTextColor(hasReacted),
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

  Color _getReactionBackgroundColor(bool hasReacted) {
    if (hasReacted) {
      return isMyMessage
          ? Colors.white.withOpacity(0.3)
          : Colors.blue.withOpacity(0.2);
    }
    return Colors.grey[200]!;
  }

  Color? _getReactionBorderColor(bool hasReacted) {
    if (hasReacted) {
      return isMyMessage ? Colors.white : Colors.blue;
    }
    return null;
  }

  Color _getReactionTextColor(bool hasReacted) {
    if (hasReacted) {
      return isMyMessage ? Colors.white : Colors.blue;
    }
    return Colors.grey[600]!;
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () => onViewProfile?.call(senderId),
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Users')
                .doc(senderId)
                .snapshots(),
        builder: (context, snapshot) {
          String? imageUrl;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              imageUrl = data['imageUrl'];
              if (imageUrl != null && imageUrl.isEmpty) imageUrl = null;
            }
          }

          if (imageUrl != null && imageUrl.isNotEmpty) {
            return CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image loading error
              },
            );
          } else {
            return CircleAvatar(
              radius: 16,
              backgroundColor: getAvatarBackgroundColor(),
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    } else if (difference.inHours > 0) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showMessageOptions(BuildContext context) {
    final List<Widget> options = [
      // Copy to clipboard option (available for all messages)
      ListTile(
        leading: const Icon(Icons.copy_outlined, color: Colors.grey),
        title: const Text('Copy to clipboard'),
        onTap: () {
          Navigator.of(context).pop();
          _copyToClipboard(context);
        },
      ),
      if (onReply != null)
        ListTile(
          leading: const Icon(Icons.reply_outlined, color: Colors.blue),
          title: const Text('Reply'),
          onTap: () {
            Navigator.of(context).pop();
            onReply?.call(message);
          },
        ),
      if (onReact != null)
        ListTile(
          leading: const Icon(
            Icons.emoji_emotions_outlined,
            color: Colors.orange,
          ),
          title: const Text('React'),
          onTap: () {
            Navigator.of(context).pop();
            _showReactionPicker(context);
          },
        ),
      if (onViewProfile != null)
        ListTile(
          leading: const Icon(Icons.person_outline, color: Colors.purple),
          title: const Text('View Profile'),
          onTap: () {
            Navigator.of(context).pop();
            onViewProfile?.call(senderId);
          },
        ),
      // Delete option (only for user's own messages)
      if (onDelete != null && isMyMessage)
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Delete Message'),
          onTap: () {
            Navigator.of(context).pop();
            _showDeleteDialog(context);
          },
        ),
    ];

    showModalBottomSheet(
      context: context,
      builder:
          (BuildContext context) =>
              Column(mainAxisSize: MainAxisSize.min, children: options),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: messageContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    final emojis = ['👍', '❤️', '😂', '😮', '😢', '😡'];

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

  /// Get current user ID - to be implemented by subclasses
  String getCurrentUserId();

  /// Check if the user can interact with this message
  /// Default implementation returns true, can be overridden by subclasses
  bool canInteractWithMessage() {
    return true;
  }
}

/// Data class for reply information
class ReplyInfo {
  final String? replyToMessageId;
  final String? replyToMessageContent;
  final String? replyToSenderName;

  const ReplyInfo({
    this.replyToMessageId,
    this.replyToMessageContent,
    this.replyToSenderName,
  });
}
