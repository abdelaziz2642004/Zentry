import 'package:flutter/material.dart';

class ConversationUtils {
  /// Formats time difference for display
  static String formatTimeDifference(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Gets user initials from name
  static String getUserInitials(String userName) {
    if (userName.isEmpty) return '?';
    return userName[0].toUpperCase();
  }

  /// Gets subtitle text style based on unread count
  static TextStyle getSubtitleTextStyle(int unreadCount) {
    return TextStyle(
      color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
      fontSize: 14,
      fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
    );
  }

  /// Gets status text based on online status and last seen
  static String getStatusText(bool isOnline, DateTime? lastSeen) {
    if (isOnline) {
      return 'Online';
    } else if (lastSeen != null) {
      return 'Last seen ${formatTimeDifference(lastSeen)}';
    } else {
      return 'Offline';
    }
  }

  /// Gets status color based on online status
  static Color getStatusColor(bool isOnline) {
    return isOnline ? Colors.green : Colors.grey[500]!;
  }

  /// Gets status icon based on online status
  static IconData? getStatusIcon(bool isOnline) {
    return isOnline ? Icons.circle : null;
  }

  /// Validates conversation data
  static bool isValidConversation(Map<String, dynamic> conversation) {
    return conversation['userId'] != null &&
        conversation['userId'].toString().isNotEmpty;
  }

  /// Gets conversation display name
  static String getConversationDisplayName(Map<String, dynamic> conversation) {
    return conversation['userName'] ?? 'Unknown';
  }

  /// Gets conversation last message
  static String getConversationLastMessage(Map<String, dynamic> conversation) {
    return conversation['lastMessage'] ?? '';
  }

  /// Gets conversation unread count
  static int getConversationUnreadCount(Map<String, dynamic> conversation) {
    return conversation['unreadCount'] ?? 0;
  }

  /// Gets conversation online status
  static bool getConversationOnlineStatus(Map<String, dynamic> conversation) {
    return conversation['isOnline'] ?? false;
  }

  /// Gets conversation last seen
  static DateTime? getConversationLastSeen(Map<String, dynamic> conversation) {
    return conversation['lastSeen'] as DateTime?;
  }

  /// Gets conversation user ID
  static String getConversationUserId(Map<String, dynamic> conversation) {
    return conversation['userId'] ?? '';
  }

  /// Gets conversation last message time
  static DateTime? getConversationLastMessageTime(
    Map<String, dynamic> conversation,
  ) {
    return conversation['lastMessageTime'] as DateTime?;
  }

  /// Checks if conversation has unread messages
  static bool hasUnreadMessages(Map<String, dynamic> conversation) {
    return getConversationUnreadCount(conversation) > 0;
  }

  /// Gets unread badge text
  static String getUnreadBadgeText(Map<String, dynamic> conversation) {
    final count = getConversationUnreadCount(conversation);
    if (count > 99) {
      return '99+';
    }
    return count.toString();
  }

  /// Gets unread badge visibility
  static bool shouldShowUnreadBadge(Map<String, dynamic> conversation) {
    return hasUnreadMessages(conversation);
  }
}
