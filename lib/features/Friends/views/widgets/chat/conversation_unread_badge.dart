import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/conversation_utils.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class ConversationUnreadBadge extends StatelessWidget {
  final Map<String, dynamic> conversation;

  const ConversationUnreadBadge({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    if (!ConversationUtils.shouldShowUnreadBadge(conversation)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(color: mainColor, shape: BoxShape.circle),
      child: Text(
        ConversationUtils.getUnreadBadgeText(conversation),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
