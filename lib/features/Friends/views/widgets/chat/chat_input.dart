import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_input_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_input_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/chat_input_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_input_blocked.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_input_friend_request.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_input_received_request.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/chat_input_normal.dart';

class ChatInput extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final bool isBlocked;
  final bool isBlockedByUser;
  final bool isFriend;
  final bool isFriendRequestPending;
  final bool isFriendRequestReceived;
  final bool isAnyRequestPending;
  final VoidCallback? onRefreshFriendshipStatus;
  final ChatMessage? replyingTo;
  final VoidCallback? onClearReply;

  const ChatInput({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.isBlocked,
    required this.isBlockedByUser,
    required this.isFriend,
    required this.isFriendRequestPending,
    required this.isFriendRequestReceived,
    required this.isAnyRequestPending,
    this.onRefreshFriendshipStatus,
    this.replyingTo,
    this.onClearReply,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _isRefreshing = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatInputCubit, ChatInputState>(
      listener: (context, state) {
        if (state is ChatInputMessageSent) {
          _messageController.clear();
          widget.onClearReply?.call();
        } else if (state is ChatInputFriendRequestSent ||
            state is ChatInputFriendRequestAccepted ||
            state is ChatInputFriendRequestRejected) {
          // Prevent multiple refresh calls
          if (!_isRefreshing) {
            _isRefreshing = true;
            // Call the refresh callback to update friendship status
            widget.onRefreshFriendshipStatus?.call();
            // Reset the cubit state after the refresh callback is called
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                context.read<ChatInputCubit>().reset();
                _isRefreshing = false;
              }
            });
          }
        } else if (state is ChatInputError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return _buildInputWidget(context, state);
      },
    );
  }

  Widget _buildInputWidget(BuildContext context, ChatInputState state) {
    final inputType = ChatInputUtils.getInputType(
      isBlocked: widget.isBlocked,
      isBlockedByUser: widget.isBlockedByUser,
      isFriend: widget.isFriend,
      isFriendRequestPending: widget.isFriendRequestPending,
      isFriendRequestReceived: widget.isFriendRequestReceived,
      isAnyRequestPending: widget.isAnyRequestPending,
    );

    // Extract loading states from the current state
    final isSendingMessage = state is ChatInputSendingMessage;
    final isSendingFriendRequest = state is ChatInputSendingFriendRequest;
    final isAcceptingFriendRequest = state is ChatInputAcceptingFriendRequest;
    final isRejectingFriendRequest = state is ChatInputRejectingFriendRequest;

    // Check if we're in a loading state or refreshing
    final isLoading =
        isSendingMessage ||
        isSendingFriendRequest ||
        isAcceptingFriendRequest ||
        isRejectingFriendRequest ||
        _isRefreshing;

    // If we're in a loading state, show a loading indicator instead of the normal input
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              isSendingFriendRequest
                  ? 'Sending friend request...'
                  : isAcceptingFriendRequest
                  ? 'Accepting friend request...'
                  : isRejectingFriendRequest
                  ? 'Rejecting friend request...'
                  : 'Updating...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    switch (inputType) {
      case ChatInputType.blocked:
        return ChatInputBlocked(isBlocked: widget.isBlocked);

      case ChatInputType.receivedRequest:
        return ChatInputReceivedRequest(
          otherUserName: widget.otherUserName,
          isAccepting: isAcceptingFriendRequest,
          isRejecting: isRejectingFriendRequest,
          isRefreshing: _isRefreshing,
          onAcceptRequest: () => _acceptFriendRequest(context),
          onRejectRequest: () => _rejectFriendRequest(context),
        );

      case ChatInputType.anyRequestPending:
      case ChatInputType.friendRequest:
        return ChatInputFriendRequest(
          otherUserName: widget.otherUserName,
          isFriendRequestPending: widget.isFriendRequestPending,
          isAnyRequestPending: widget.isAnyRequestPending,
          isLoading: isSendingFriendRequest,
          isRefreshing: _isRefreshing,
          onSendFriendRequest: () => _showSendFriendRequestDialog(context),
        );

      case ChatInputType.normal:
        return ChatInputNormal(
          messageController: _messageController,
          replyingTo: widget.replyingTo,
          isSending: isSendingMessage,
          onClearReply: widget.onClearReply,
          onSendMessage: () => _sendMessage(context),
        );
    }
  }

  void _sendMessage(BuildContext context) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatInputCubit>().sendMessage(
        receiverId: widget.otherUserId,
        receiverName: widget.otherUserName,
        content: message,
        replyTo: widget.replyingTo,
      );
    }
  }

  void _showSendFriendRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Friend Request'),
            content: Text('Send a friend request to ${widget.otherUserName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _sendFriendRequest(context);
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  Future<void> _sendFriendRequest(BuildContext context) async {
    context.read<ChatInputCubit>().sendFriendRequest(
      receiverId: widget.otherUserId,
    );
  }

  Future<void> _acceptFriendRequest(BuildContext context) async {
    context.read<ChatInputCubit>().acceptFriendRequest(widget.otherUserId);
  }

  Future<void> _rejectFriendRequest(BuildContext context) async {
    context.read<ChatInputCubit>().rejectFriendRequest(widget.otherUserId);
  }
}
