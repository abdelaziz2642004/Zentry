import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/chat/chat_message_bubble.dart';

class ChatMessagesList extends StatefulWidget {
  final String roomCode;
  final FireUser currentUser;
  final ScrollController scrollController;

  const ChatMessagesList({
    super.key,
    required this.roomCode,
    required this.currentUser,
    required this.scrollController,
  });

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList> {
  @override
  void initState() {
    super.initState();
    // Start listening to chat messages
    context.read<RoomChatCubit>().startListeningToChat(widget.roomCode);
  }

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomChatCubit, ChatStates>(
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
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatErrorState) {
          return _buildErrorState(state.error);
        } else if (state is ChatMessagesLoaded) {
          if (state.messages.isEmpty) {
            return _buildEmptyState();
          }
          return _buildMessagesList(state.messages);
        }

        return const Center(child: Text('No messages'));
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Error loading messages',
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: Colors.grey[400], size: 48),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List messages) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMyMessage = message.senderId == widget.currentUser.id;

        return ChatMessageBubble(
          message: message,
          isMyMessage: isMyMessage,
          onDelete: () {
            context.read<RoomChatCubit>().deleteMessage(message.id);
          },
        );
      },
    );
  }
}
