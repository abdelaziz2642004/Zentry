import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/message_bubble.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/room_invitation_bubble.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/screens/view_profile_screen.dart';

class ChatMessagesList extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final ScrollController scrollController;
  final VoidCallback onScrollToBottom;
  final bool isBlocked;
  final bool isBlockedByUser;
  final bool isFriend;
  final bool isAnyRequestPending;
  final Function(ChatMessage?)? onReplyStateChanged;

  const ChatMessagesList({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.scrollController,
    required this.onScrollToBottom,
    required this.isBlocked,
    required this.isBlockedByUser,
    required this.isFriend,
    required this.isAnyRequestPending,
    this.onReplyStateChanged,
  });

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList> {
  DateTime? _lastMarkedAsRead;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is MessagesLoadedState) {
          _handleMessagesLoaded();
        } else if (state is RoomInvitationSentState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room invitation sent!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MessagesLoadedState) {
          return _buildMessagesList(state);
        } else if (state is ChatErrorState) {
          return Center(child: Text(state.error));
        }

        return const Center(child: Text(''));
      },
    );
  }

  Widget _buildMessagesList(MessagesLoadedState state) {
    if (state.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
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

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final currentUser = FirebaseAuth.instance.currentUser;
        final isMe = currentUser?.uid == message.senderId;

        if (message.type == MessageType.roomInvitation) {
          return RoomInvitationBubble(
            message: message,
            isMe: isMe,
            onJoinRoom: () => _handleJoinRoom(message),
            onViewProfile: (userId) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ViewProfileScreen(userId: userId),
                ),
              );
            },
          );
        } else {
          return MessageBubble(
            message: message,
            isMe: isMe,
            isBlocked: widget.isBlocked,
            isBlockedByUser: widget.isBlockedByUser,
            isFriend: widget.isFriend,
            isAnyRequestPending: widget.isAnyRequestPending,
            onDelete: () {
              context.read<ChatCubit>().deleteMessage(message.id);
            },
            onReply: (replyToMessage) {
              // Set the reply state
              widget.onReplyStateChanged?.call(replyToMessage);
            },
            onReact: (emoji) {
              context.read<ChatCubit>().toggleReaction(message.id, emoji);
            },
            onViewProfile: (userId) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ViewProfileScreen(userId: userId),
                ),
              );
            },
          );
        }
      },
    );
  }

  void _handleMessagesLoaded() {
    final chatCubit = BlocProvider.of<ChatCubit>(context);

    // Mark messages as read when new messages arrive while user is in chat
    // Use debounce to avoid calling too frequently (max once per 2 seconds)
    final now = DateTime.now();
    if (_lastMarkedAsRead == null ||
        now.difference(_lastMarkedAsRead!).inSeconds >= 2) {
      chatCubit.markMessagesAsRead(widget.otherUserId);
      _lastMarkedAsRead = now;
    }

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onScrollToBottom();
    });
  }

  void _handleJoinRoom(dynamic message) {
    // This will be handled by the parent widget
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Join room functionality will be implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
