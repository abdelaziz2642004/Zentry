import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/chat_messages_utils.dart';

class ChatMessagesEmpty extends StatelessWidget {
  final bool isBlocked;
  final bool isBlockedByUser;
  final bool isFriend;
  final bool isAnyRequestPending;

  const ChatMessagesEmpty({
    super.key,
    required this.isBlocked,
    required this.isBlockedByUser,
    required this.isFriend,
    required this.isAnyRequestPending,
  });

  @override
  Widget build(BuildContext context) {
    final message = ChatMessagesUtils.getEmptyStateMessage(
      isBlocked: isBlocked,
      isBlockedByUser: isBlockedByUser,
      isFriend: isFriend,
      isAnyRequestPending: isAnyRequestPending,
    );

    final subtitle = ChatMessagesUtils.getEmptyStateSubtitle(
      isBlocked: isBlocked,
      isBlockedByUser: isBlockedByUser,
      isFriend: isFriend,
      isAnyRequestPending: isAnyRequestPending,
    );

    final icon = ChatMessagesUtils.getEmptyStateIcon(
      isBlocked: isBlocked,
      isBlockedByUser: isBlockedByUser,
      isFriend: isFriend,
      isAnyRequestPending: isAnyRequestPending,
    );

    final color = ChatMessagesUtils.getEmptyStateColor(
      isBlocked: isBlocked,
      isBlockedByUser: isBlockedByUser,
      isFriend: isFriend,
      isAnyRequestPending: isAnyRequestPending,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, color: color)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
