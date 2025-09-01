import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/chat_messages_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/room_joining_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_messages_empty.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_message_item.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';

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
      return ChatMessagesEmpty(
        isBlocked: widget.isBlocked,
        isBlockedByUser: widget.isBlockedByUser,
        isFriend: widget.isFriend,
        isAnyRequestPending: widget.isAnyRequestPending,
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return ChatMessageItem(
          message: message,
          isBlocked: widget.isBlocked,
          isBlockedByUser: widget.isBlockedByUser,
          isFriend: widget.isFriend,
          isAnyRequestPending: widget.isAnyRequestPending,
          onDelete: () {
            context.read<ChatCubit>().deleteMessage(message.id);
          },
          onReplyStateChanged: (replyToMessage) {
            widget.onReplyStateChanged?.call(replyToMessage);
          },
          onReact: (emoji) {
            context.read<ChatCubit>().toggleReaction(message.id, emoji);
          },
          onJoinRoom: () => _handleJoinRoom(message),
        );
      },
    );
  }

  void _handleMessagesLoaded() {
    final chatCubit = BlocProvider.of<ChatCubit>(context);

    // Mark messages as read when new messages arrive while user is in chat
    if (ChatMessagesUtils.shouldMarkAsRead(_lastMarkedAsRead)) {
      chatCubit.markMessagesAsRead(widget.otherUserId);
      _lastMarkedAsRead = DateTime.now();
    }

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onScrollToBottom();
    });
  }

  void _handleJoinRoom(ChatMessage message) async {
    final roomCubit = BlocProvider.of<RoomCubit>(context);

    // Check if can join room
    if (!RoomJoiningUtils.canJoinRoom(message, roomCubit)) {
      final errorMessage = RoomJoiningUtils.getRoomJoiningErrorMessage(
        message,
        roomCubit,
      );
      RoomJoiningUtils.showJoiningError(context, errorMessage);
      return;
    }

    // Get room code
    final roomCode = RoomJoiningUtils.getRoomCode(message);
    if (roomCode == null) {
      RoomJoiningUtils.showJoiningError(context, 'Invalid room invitation');
      return;
    }

    // Show loading indicator
    RoomJoiningUtils.showJoiningIndicator(context);

    try {
      // Navigate to room screen
      if (context.mounted) {
        RoomJoiningUtils.navigateToRoom(context, roomCode, roomCubit);
      }
    } catch (e) {
      if (context.mounted) {
        RoomJoiningUtils.showJoiningError(context, 'Failed to join room');
      }
    }
  }
}
