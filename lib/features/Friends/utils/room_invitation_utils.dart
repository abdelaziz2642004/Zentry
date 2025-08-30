import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class RoomInvitationUtils {
  /// Gets room invitation bubble color based on sender
  static Color getInvitationBubbleColor(bool isMe) {
    return isMe ? mainColor : Colors.blue[50]!;
  }

  /// Gets room invitation border color based on sender
  static Color getInvitationBorderColor(bool isMe) {
    return isMe ? mainColor : Colors.blue[200]!;
  }

  /// Gets room invitation icon color based on sender
  static Color getInvitationIconColor(bool isMe) {
    return isMe ? Colors.white : Colors.blue[600]!;
  }

  /// Gets room invitation title color based on sender
  static Color getInvitationTitleColor(bool isMe) {
    return isMe ? Colors.white : Colors.blue[600]!;
  }

  /// Gets room invitation content color based on sender
  static Color getInvitationContentColor(bool isMe) {
    return isMe ? Colors.white : Colors.grey[800]!;
  }

  /// Gets room info background color based on sender
  static Color getRoomInfoBackgroundColor(bool isMe) {
    return isMe ? Colors.white.withOpacity(0.2) : Colors.blue[100]!;
  }

  /// Gets room info text color based on sender
  static Color getRoomInfoTextColor(bool isMe) {
    return isMe ? Colors.white : Colors.blue[600]!;
  }

  /// Gets join button background color based on sender
  static Color getJoinButtonBackgroundColor(bool isMe) {
    return isMe ? Colors.white : mainColor;
  }

  /// Gets join button text color based on sender
  static Color getJoinButtonTextColor(bool isMe) {
    return isMe ? mainColor : Colors.white;
  }

  /// Gets timestamp color based on sender
  static Color getTimestampColor(bool isMe) {
    return isMe ? Colors.white70 : Colors.grey[500]!;
  }

  /// Gets sender name color
  static Color getSenderNameColor() {
    return Colors.grey[600]!;
  }

  /// Gets room display name
  static String getRoomDisplayName(ChatMessage message) {
    return message.roomName ?? message.roomCode ?? 'Unknown Room';
  }

  /// Gets room invitation title
  static String getInvitationTitle() {
    return 'Room Invitation';
  }

  /// Gets join room button text
  static String getJoinButtonText() {
    return 'Join Room';
  }

  /// Validates room invitation message
  static bool isValidRoomInvitation(ChatMessage message) {
    return message.type == MessageType.roomInvitation &&
        (message.roomCode != null || message.roomName != null);
  }

  /// Gets room invitation icon
  static IconData getInvitationIcon() {
    return Icons.meeting_room;
  }

  /// Gets room info icon
  static IconData getRoomInfoIcon() {
    return Icons.video_call;
  }

  /// Gets max width for invitation bubble
  static double getMaxInvitationWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.75;
  }

  /// Checks if message has room name
  static bool hasRoomName(ChatMessage message) {
    return message.roomName != null && message.roomName!.isNotEmpty;
  }

  /// Checks if message has room code
  static bool hasRoomCode(ChatMessage message) {
    return message.roomCode != null && message.roomCode!.isNotEmpty;
  }

  /// Gets room identifier (name or code)
  static String getRoomIdentifier(ChatMessage message) {
    if (hasRoomName(message)) {
      return message.roomName!;
    }
    if (hasRoomCode(message)) {
      return message.roomCode!;
    }
    return 'Unknown Room';
  }
}
