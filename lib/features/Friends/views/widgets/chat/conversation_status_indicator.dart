import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/conversation_utils.dart';

class ConversationStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSeen;

  const ConversationStatusIndicator({
    super.key,
    required this.isOnline,
    this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isOnline) ...[
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            ConversationUtils.getStatusText(isOnline, lastSeen),
            style: TextStyle(
              color: ConversationUtils.getStatusColor(isOnline),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          Text(
            ConversationUtils.getStatusText(isOnline, lastSeen),
            style: TextStyle(
              color: ConversationUtils.getStatusColor(isOnline),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
