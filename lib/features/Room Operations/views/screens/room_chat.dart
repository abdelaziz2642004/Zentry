import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/chat/chat_header.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/chat/chat_input_field.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/chat/chat_message_bubble.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

class RoomChat extends StatefulWidget {
  final String roomCode;
  final FireUser currentUser;

  const RoomChat({
    super.key,
    required this.roomCode,
    required this.currentUser,
  });

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  final ScrollController _scrollController = ScrollController();
  dynamic _replyingTo;

  @override
  void initState() {
    super.initState();
    // Start listening to chat messages
    context.read<RoomChatCubit>().startListeningToChat(widget.roomCode);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat Header
        // Container(
        //   decoration: BoxDecoration(
        //     color: const Color(0xFF2CACAD).withOpacity(0.1),
        //     borderRadius: const BorderRadius.only(
        //       topLeft: Radius.circular(20),
        //       topRight: Radius.circular(20),
        //     ),
        //   ),
        //   child: const ChatHeader(),
        // ),

        // Messages List
        Expanded(
          child: BlocConsumer<RoomChatCubit, ChatStates>(
            listener: (context, state) {
              if (state is ChatMessagesLoaded) {
                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
            },
            builder: (context, state) {
              if (state is ChatLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF75E2E0),
                    ),
                  ),
                );
              } else if (state is ChatErrorState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFF0C7075),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading messages',
                        style: TextStyle(
                          color: Color(0xFFD9F5F0),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error,
                        style: const TextStyle(
                          color: Color(0xFF75E2E0),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else if (state is ChatMessagesLoaded) {
                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: const Color(0xFF0C7075).withOpacity(0.5),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No messages yet',
                          style: const TextStyle(
                            color: const Color(0xFFD9F5F0),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start the conversation!',
                          style: const TextStyle(
                            color: const Color(0xFF75E2E0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMyMessage =
                        message.senderId == widget.currentUser.id;

                    return ChatMessageBubble(
                      message: message,
                      isMyMessage: isMyMessage,
                      onDelete: () {
                        context.read<RoomChatCubit>().deleteMessage(message.id);
                      },
                      onReact: (emoji) {
                        context.read<RoomChatCubit>().toggleReaction(
                          message.id,
                          emoji,
                        );
                      },
                      onReply: (replyToMessage) {
                        setState(() {
                          _replyingTo = replyToMessage;
                        });
                      },
                      onViewProfile: (userId) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => ProfilePopupDialog(userId: userId),
                        );
                      },
                    );
                  },
                );
              }

              return const Center(
                child: Text(
                  'No messages',
                  style: TextStyle(color: Color(0xFFD9F5F0)),
                ),
              );
            },
          ),
        ),

        // Chat Input
        ChatInputField(
          replyingTo: _replyingTo,
          onReplyCleared: () {
            setState(() {
              _replyingTo = null;
            });
          },
          onSendMessage: (message) {
            if (_replyingTo != null) {
              // Send reply message
              context.read<RoomChatCubit>().sendReplyMessage(
                message: message,
                replyToMessageId: _replyingTo.id,
                replyToMessageContent: _replyingTo.message,
                replyToSenderName: _replyingTo.senderName ?? 'Unknown',
              );
            } else {
              // Send normal message
              context.read<RoomChatCubit>().sendMessage(
                message,
                widget.currentUser,
              );
            }
          },
        ),
      ],
    );
  }
}
