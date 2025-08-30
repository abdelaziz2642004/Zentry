import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:intl/intl.dart';

class MessageBubbleUtils {
  /// Gets message bubble color based on sender
  static Color getMessageBubbleColor(bool isMe) {
    return isMe ? mainColor : Colors.grey[100]!;
  }

  /// Gets message text color based on sender
  static Color getMessageTextColor(bool isMe) {
    return isMe ? Colors.white : Colors.grey[800]!;
  }

  /// Gets message timestamp color based on sender
  static Color getTimestampColor(bool isMe) {
    return isMe ? Colors.white70 : Colors.grey[500]!;
  }

  /// Gets reply preview background color based on sender
  static Color getReplyPreviewBackgroundColor(bool isMe) {
    return isMe ? Colors.white.withOpacity(0.2) : Colors.grey[200]!;
  }

  /// Gets reply preview text color based on sender
  static Color getReplyPreviewTextColor(bool isMe) {
    return isMe ? Colors.white70 : Colors.grey[600]!;
  }

  /// Gets reply preview content color based on sender
  static Color getReplyPreviewContentColor(bool isMe) {
    return isMe ? Colors.white70 : Colors.grey[700]!;
  }

  /// Gets sender name color
  static Color getSenderNameColor() {
    return Colors.grey[600]!;
  }

  /// Gets avatar background color based on sender
  static Color getAvatarBackgroundColor(bool isMe) {
    return isMe ? mainColor.withOpacity(0.8) : Colors.grey[400]!;
  }

  /// Gets user initials from name
  static String getUserInitials(String senderName) {
    if (senderName.isEmpty) return '?';
    return senderName[0].toUpperCase();
  }

  /// Formats timestamp for display
  static String formatTimestamp(DateTime timestamp) {
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

  /// Checks if user can interact with message
  static bool canInteractWithMessage({
    required bool isFriend,
    required bool isBlocked,
    required bool isBlockedByUser,
    required bool isAnyRequestPending,
  }) {
    return isFriend && !isBlocked && !isBlockedByUser && !isAnyRequestPending;
  }

  /// Gets reaction background color based on state
  static Color getReactionBackgroundColor({
    required bool hasReacted,
    required bool isMe,
  }) {
    if (hasReacted) {
      return isMe ? Colors.white.withOpacity(0.3) : mainColor.withOpacity(0.2);
    }
    return Colors.grey[200]!;
  }

  /// Gets reaction border color based on state
  static Color? getReactionBorderColor({
    required bool hasReacted,
    required bool isMe,
  }) {
    if (hasReacted) {
      return isMe ? Colors.white : mainColor;
    }
    return null;
  }

  /// Gets reaction text color based on state
  static Color getReactionTextColor({
    required bool hasReacted,
    required bool isMe,
  }) {
    if (hasReacted) {
      return isMe ? Colors.white : mainColor;
    }
    return Colors.grey[600]!;
  }

  /// Gets available reaction emojis
  static List<String> getAvailableEmojis() {
    return ['👍', '❤️', '😂', '😮', '😢', '😡'];
  }

  /// Validates message data
  static bool isValidMessage(ChatMessage message) {
    return message.content.isNotEmpty && message.senderId.isNotEmpty;
  }

  /// Gets reply preview text
  static String getReplyPreviewText(String? replyToSenderName) {
    return 'Replying to ${replyToSenderName ?? 'Unknown'}';
  }

  /// Checks if message has reply
  static bool hasReply(ChatMessage message) {
    return message.replyToMessageId != null;
  }

  /// Checks if message has reactions
  static bool hasReactions(ChatMessage message) {
    return message.reactions != null && message.reactions!.isNotEmpty;
  }

  /// Gets reaction count for specific emoji
  static int getReactionCount(ChatMessage message, String emoji) {
    return message.reactions?[emoji]?.length ?? 0;
  }

  /// Checks if current user has reacted with specific emoji
  static bool hasUserReacted(
    ChatMessage message,
    String emoji,
    String currentUserId,
  ) {
    return message.reactions?[emoji]?.contains(currentUserId) ?? false;
  }

  /// Gets max width for message bubble
  static double getMaxMessageWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.75;
  }
}
