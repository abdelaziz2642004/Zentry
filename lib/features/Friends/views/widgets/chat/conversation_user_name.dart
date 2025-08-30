import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';

class ConversationUserName extends StatelessWidget {
  final String userId;
  final String fallbackName;
  final TextStyle? style;

  const ConversationUserName({
    super.key,
    required this.userId,
    required this.fallbackName,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: UserService().getUserNameStream(userId),
      builder: (context, snapshot) {
        final displayName = snapshot.data ?? fallbackName;
        return Text(
          displayName,
          style:
              style ??
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        );
      },
    );
  }
}
