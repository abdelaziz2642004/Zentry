import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';

class ChatMessagesUtils {
  /// Determines if a message is sent by the current user
  static bool isMessageFromMe(ChatMessage message) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid == message.senderId;
  }

  /// Gets the appropriate message bubble based on message type
  static MessageBubbleType getMessageBubbleType(ChatMessage message) {
    switch (message.type) {
      case MessageType.roomInvitation:
        return MessageBubbleType.roomInvitation;
      case MessageType.text:
        return MessageBubbleType.text;
      default:
        return MessageBubbleType.text;
    }
  }

  /// Validates room invitation message
  static bool isValidRoomInvitation(ChatMessage message) {
    return message.type == MessageType.roomInvitation &&
        message.roomCode != null &&
        message.roomCode!.isNotEmpty;
  }

  /// Gets room code from invitation message
  static String? getRoomCode(ChatMessage message) {
    if (isValidRoomInvitation(message)) {
      return message.roomCode;
    }
    return null;
  }

  /// Formats message timestamp for display
  static String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  /// Checks if messages should be marked as read
  static bool shouldMarkAsRead(
    DateTime? lastMarkedAsRead, {
    int debounceSeconds = 2,
  }) {
    if (lastMarkedAsRead == null) return true;

    final now = DateTime.now();
    return now.difference(lastMarkedAsRead).inSeconds >= debounceSeconds;
  }

  /// Gets empty state message based on context
  static String getEmptyStateMessage({
    bool isBlocked = false,
    bool isBlockedByUser = false,
    bool isFriend = false,
    bool isAnyRequestPending = false,
  }) {
    if (isBlocked || isBlockedByUser) {
      return 'Messages are blocked';
    }

    if (!isFriend) {
      if (isAnyRequestPending) {
        return 'Become friends to start chatting';
      }
      return 'Send a friend request to start chatting';
    }

    return 'No messages yet';
  }

  /// Gets empty state subtitle based on context
  static String getEmptyStateSubtitle({
    bool isBlocked = false,
    bool isBlockedByUser = false,
    bool isFriend = false,
    bool isAnyRequestPending = false,
  }) {
    if (isBlocked || isBlockedByUser) {
      return 'Unblock to continue the conversation';
    }

    if (!isFriend) {
      if (isAnyRequestPending) {
        return 'Wait for them to accept your request';
      }
      return 'Start the conversation!';
    }

    return 'Start the conversation!';
  }

  /// Gets empty state icon based on context
  static IconData getEmptyStateIcon({
    bool isBlocked = false,
    bool isBlockedByUser = false,
    bool isFriend = false,
    bool isAnyRequestPending = false,
  }) {
    if (isBlocked || isBlockedByUser) {
      return Icons.block;
    }

    if (!isFriend) {
      if (isAnyRequestPending) {
        return Icons.schedule;
      }
      return Icons.person_add;
    }

    return Icons.chat_bubble_outline;
  }

  /// Gets empty state color based on context
  static Color getEmptyStateColor({
    bool isBlocked = false,
    bool isBlockedByUser = false,
    bool isFriend = false,
    bool isAnyRequestPending = false,
  }) {
    if (isBlocked || isBlockedByUser) {
      return Colors.red;
    }

    if (!isFriend) {
      if (isAnyRequestPending) {
        return Colors.orange;
      }
      return Colors.blue;
    }

    return Colors.grey;
  }
}

enum MessageBubbleType { text, roomInvitation }
