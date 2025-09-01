import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/group_message.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/group_chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_message_bubble.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

class GroupMessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final String currentUserId;
  final VoidCallback onScrollToBottom;
  final Function(GroupMessage)? onReply;

  const GroupMessagesList({
    super.key,
    required this.scrollController,
    required this.currentUserId,
    required this.onScrollToBottom,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupChatCubit, GroupChatState>(
      listener: (context, state) {
        if (state is GroupChatLoadedState) {
          // Auto-scroll to bottom when new messages arrive
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onScrollToBottom();
          });
        }
      },
      builder: (context, state) {
        if (state is GroupChatLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GroupChatErrorState) {
          return _buildErrorState(state.error);
        } else if (state is GroupChatLoadedState) {
          if (state.messages.isEmpty) {
            return _buildEmptyState();
          }
          return _buildMessagesList(context, state);
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, GroupChatLoadedState state) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isCurrentUser = message.senderId == currentUserId;

        return GroupMessageBubble(
          message: message,
          isMyMessage: isCurrentUser,
          onDelete: () {
            context.read<GroupChatCubit>().deleteMessage(message.id);
          },
          onReact: (emoji) {
            context.read<GroupChatCubit>().toggleReaction(message.id, emoji);
          },
          onReply: (replyToMessage) {
            onReply?.call(replyToMessage);
          },
          onViewProfile: (userId) {
            showDialog(
              context: context,
              builder: (context) => ProfilePopupDialog(userId: userId),
            );
          },
        );
      },
    );
  }
}
