import 'package:flutter/material.dart';

class ChatInputBlocked extends StatelessWidget {
  final bool isBlocked;

  const ChatInputBlocked({super.key, required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isBlocked
                  ? 'You have blocked this user'
                  : 'This user has blocked you',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
