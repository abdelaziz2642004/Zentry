import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class ChatInputUtils {
  /// Determines the appropriate input type based on friendship status
  static ChatInputType getInputType({
    required bool isBlocked,
    required bool isBlockedByUser,
    required bool isFriend,
    required bool isFriendRequestPending,
    required bool isFriendRequestReceived,
    required bool isAnyRequestPending,
  }) {
    if (isBlocked || isBlockedByUser) {
      return ChatInputType.blocked;
    }

    if (!isFriend) {
      if (isFriendRequestReceived) {
        return ChatInputType.receivedRequest;
      }
      if (isAnyRequestPending) {
        return ChatInputType.anyRequestPending;
      }
      return ChatInputType.friendRequest;
    }

    return ChatInputType.normal;
  }

  /// Gets the appropriate input title based on type
  static String getInputTitle(ChatInputType type, String otherUserName) {
    switch (type) {
      case ChatInputType.blocked:
        return 'Blocked';
      case ChatInputType.receivedRequest:
        return 'Friend request received from $otherUserName';
      case ChatInputType.anyRequestPending:
        return 'Request pending';
      case ChatInputType.friendRequest:
        return 'Send friend request';
      case ChatInputType.normal:
        return 'Send message';
    }
  }

  /// Gets the appropriate input subtitle based on type
  static String getInputSubtitle(
    ChatInputType type,
    bool isFriendRequestPending,
  ) {
    switch (type) {
      case ChatInputType.blocked:
        return 'You have blocked this user';
      case ChatInputType.receivedRequest:
        return 'Accept or decline the friend request';
      case ChatInputType.anyRequestPending:
        return isFriendRequestPending
            ? 'Friend request sent - waiting for response'
            : 'You need to be friends to send messages';
      case ChatInputType.friendRequest:
        return isFriendRequestPending
            ? 'Friend request sent - waiting for response'
            : 'You need to be friends to send messages';
      case ChatInputType.normal:
        return 'Type a message...';
    }
  }

  /// Gets the appropriate input icon based on type
  static IconData getInputIcon(
    ChatInputType type,
    bool isFriendRequestPending,
  ) {
    switch (type) {
      case ChatInputType.blocked:
        return Icons.block;
      case ChatInputType.receivedRequest:
        return Icons.person_add;
      case ChatInputType.anyRequestPending:
        return Icons.schedule;
      case ChatInputType.friendRequest:
        return isFriendRequestPending ? Icons.schedule : Icons.person_off;
      case ChatInputType.normal:
        return Icons.send;
    }
  }

  /// Gets the appropriate input color based on type
  static Color getInputColor(ChatInputType type) {
    switch (type) {
      case ChatInputType.blocked:
        return Colors.grey;
      case ChatInputType.receivedRequest:
        return Colors.blue;
      case ChatInputType.anyRequestPending:
        return Colors.orange;
      case ChatInputType.friendRequest:
        return Colors.orange;
      case ChatInputType.normal:
        return mainColor;
    }
  }

  /// Gets the appropriate background color based on type
  static Color getBackgroundColor(
    ChatInputType type,
    bool isFriendRequestPending,
  ) {
    switch (type) {
      case ChatInputType.blocked:
        return Colors.grey[100]!;
      case ChatInputType.receivedRequest:
        return Colors.blue[50]!;
      case ChatInputType.anyRequestPending:
        return Colors.orange[50]!;
      case ChatInputType.friendRequest:
        return isFriendRequestPending ? Colors.orange[50]! : Colors.grey[100]!;
      case ChatInputType.normal:
        return Colors.white;
    }
  }

  /// Gets the appropriate border color based on type
  static Color getBorderColor(ChatInputType type, bool isFriendRequestPending) {
    switch (type) {
      case ChatInputType.blocked:
        return Colors.grey[300]!;
      case ChatInputType.receivedRequest:
        return Colors.blue[200]!;
      case ChatInputType.anyRequestPending:
        return Colors.orange[200]!;
      case ChatInputType.friendRequest:
        return isFriendRequestPending ? Colors.orange[200]! : Colors.grey[300]!;
      case ChatInputType.normal:
        return Colors.grey[300]!;
    }
  }

  /// Validates message content
  static String? validateMessage(String message) {
    if (message.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    if (message.trim().length > 1000) {
      return 'Message is too long (max 1000 characters)';
    }
    return null;
  }

  /// Formats message for sending
  static String formatMessage(String message) {
    return message.trim();
  }

  /// Gets reply preview text
  static String getReplyPreviewText(String senderName, String content) {
    return 'Replying to $senderName: $content';
  }
}

enum ChatInputType {
  blocked,
  receivedRequest,
  anyRequestPending,
  friendRequest,
  normal,
}
