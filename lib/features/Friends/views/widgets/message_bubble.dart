import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:intl/intl.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[_buildAvatar(), const SizedBox(width: 8)],
          Flexible(child: _buildMessageBubble(context)),
          if (isMe) ...[const SizedBox(width: 8), _buildAvatar()],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? mainColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reply preview
            if (message.replyToMessageId != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color:
                      isMe ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Replying to ${message.replyToSenderName ?? 'Unknown'}',
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.replyToMessageContent ?? '',
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey[700],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],

            if (!isMe) ...[
              Text(
                message.senderName,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.grey[800],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),

            // Reactions
            if (message.reactions != null && message.reactions!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children:
                    message.reactions!.entries.map((entry) {
                      final emoji = entry.key;
                      final userCount = entry.value.length;
                      final currentUserId =
                          FirebaseAuth.instance.currentUser?.uid;
                      final hasReacted = entry.value.contains(currentUserId);
                      final canInteract =
                          isFriend &&
                          !isBlocked &&
                          !isBlockedByUser &&
                          !isAnyRequestPending;

                      return GestureDetector(
                        onTap: canInteract ? () => onReact?.call(emoji) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                hasReacted
                                    ? (isMe
                                        ? Colors.white.withOpacity(0.3)
                                        : mainColor.withOpacity(0.2))
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border:
                                hasReacted
                                    ? Border.all(
                                      color: isMe ? Colors.white : mainColor,
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
                                    color:
                                        hasReacted
                                            ? (isMe ? Colors.white : mainColor)
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],

            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Listen to user's image URL from Firestore
    return GestureDetector(
      onTap: () => onViewProfile?.call(message.senderId),
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(FirebaseConstants.usersCollection)
                .doc(message.senderId)
                .snapshots(),
        builder: (context, snapshot) {
          String? imageUrl;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              imageUrl = data[FirebaseConstants.imageUrlField];
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
              backgroundColor:
                  isMe ? mainColor.withOpacity(0.8) : Colors.grey[400],
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : '?',
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
    final canInteract =
        isFriend && !isBlocked && !isBlockedByUser && !isAnyRequestPending;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
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
                    title: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteDialog(context);
                    },
                  ),
                ],
              ],
            ),
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
}
