import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/chat/chat_header.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/chat/chat_input_field.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/chat/chat_message_list.dart';

class ChatContainer extends StatelessWidget {
  final String roomCode;
  final FireUser currentUser;
  final ScrollController scrollController;

  const ChatContainer({
    super.key,
    required this.roomCode,
    required this.currentUser,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Chat Header
          const ChatHeader(),

          // Messages List
          Expanded(
            child: ChatMessagesList(
              roomCode: roomCode,
              currentUser: currentUser,
              scrollController: scrollController,
            ),
          ),

          // Chat Input
          ChatInputField(
            onSendMessage: (message) {
              // This will be handled by the parent widget
            },
          ),
        ],
      ),
    );
  }
}
