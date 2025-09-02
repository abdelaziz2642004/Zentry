import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/group_message.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/group_chat_cubit.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class GroupMessageInput extends StatefulWidget {
  final GroupMessage? replyingTo;
  final VoidCallback onReplyCleared;

  const GroupMessageInput({
    super.key,
    this.replyingTo,
    required this.onReplyCleared,
  });

  @override
  State<GroupMessageInput> createState() => _GroupMessageInputState();
}

class _GroupMessageInputState extends State<GroupMessageInput> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final chatCubit = context.read<GroupChatCubit>();

      if (widget.replyingTo != null) {
        // Send reply message
        chatCubit.sendReplyMessage(
          message: message,
          replyToMessageId: widget.replyingTo!.id,
          replyToMessageContent: widget.replyingTo!.message,
          replyToSenderName: widget.replyingTo!.senderName,
        );
      } else {
        // Send normal message
        chatCubit.sendMessage(message);
      }

      _messageController.clear();
      widget.onReplyCleared();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF05161A).withOpacity(0.9),
            const Color(0xFF072E33).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2CACAD).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Reply preview
          if (widget.replyingTo != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2CACAD).withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF2CACAD).withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2CACAD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${widget.replyingTo!.senderName}',
                          style: const TextStyle(
                            color: Color(0xFF2CACAD),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.replyingTo!.message,
                          style: TextStyle(
                            color: const Color(0xFFD9F5F0).withOpacity(0.8),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onReplyCleared,
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: const Color(0xFFD9F5F0).withOpacity(0.7),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],

          // Message input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Color(0xFFD9F5F0)),
                    decoration: InputDecoration(
                      hintText:
                          widget.replyingTo != null
                              ? 'Reply to message...'
                              : 'Type a message...',
                      hintStyle: TextStyle(
                        color: const Color(0xFFD9F5F0).withOpacity(0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2CACAD).withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<GroupChatCubit, GroupChatState>(
                  builder: (context, state) {
                    final isLoading =
                        state is GroupChatLoadedState && state.isSending;
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2CACAD),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2CACAD).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: isLoading ? null : _sendMessage,
                        icon:
                            isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF05161A),
                                    ),
                                  ),
                                )
                                : const Icon(
                                  Icons.send,
                                  color: Color(0xFF05161A),
                                ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
