import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

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
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isBlocked || widget.isBlockedByUser) {
      return _buildBlockedInput();
    }

    if (!widget.isFriend) {
      if (widget.isFriendRequestReceived) {
        return _buildReceivedRequestInput();
      }
      if (widget.isAnyRequestPending) {
        return _buildAnyRequestPendingInput();
      }
      return _buildFriendRequestInput();
    }

    return _buildNormalInput();
  }

  Widget _buildBlockedInput() {
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
              widget.isBlocked
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

  Widget _buildAnyRequestPendingInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border(top: BorderSide(color: Colors.orange[200]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Friend request pending - waiting for response',
              style: TextStyle(color: Colors.orange[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedRequestInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(top: BorderSide(color: Colors.blue[200]!)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.person_add, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.otherUserName} sent you a friend request',
                  style: TextStyle(color: Colors.blue[700], fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _acceptFriendRequest(),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectFriendRequest(),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendRequestInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            widget.isFriendRequestPending
                ? Colors.orange[50]
                : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color:
                widget.isFriendRequestPending
                    ? Colors.orange[200]!
                    : Colors.grey[300]!,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                widget.isFriendRequestPending
                    ? Icons.schedule
                    : Icons.person_off,
                color:
                    widget.isFriendRequestPending
                        ? Colors.orange[700]
                        : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isFriendRequestPending
                      ? 'Friend request sent - waiting for response'
                      : 'You need to be friends to send messages',
                  style: TextStyle(
                    color:
                        widget.isFriendRequestPending
                            ? Colors.orange[700]
                            : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (!widget.isFriendRequestPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSendFriendRequestDialog(),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Send Friend Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNormalInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: mainColor),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final chatCubit = BlocProvider.of<ChatCubit>(context);
      chatCubit.sendMessage(
        receiverId: widget.otherUserId,
        receiverName: widget.otherUserName,
        content: message,
      );
      _messageController.clear();
    }
  }

  void _showSendFriendRequestDialog() {
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
                  await _sendFriendRequest();
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  Future<void> _sendFriendRequest() async {
    try {
      final friendsService = FriendsService();
      await friendsService.sendFriendRequestById(
        receiverId: widget.otherUserId,
        message: 'Hi! I\'d like to be your friend.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend request sent!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRefreshFriendshipStatus?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending friend request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _acceptFriendRequest() async {
    try {
      final friendsService = FriendsService();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Get the friend request ID
      final requestId = await friendsService.getFriendRequestId(
        widget.otherUserId,
        currentUserId,
      );

      if (requestId != null) {
        await friendsService.acceptFriendRequest(requestId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request accepted!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onRefreshFriendshipStatus?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error accepting friend request';
        if (e.toString().contains('blocked')) {
          errorMessage =
              'Cannot accept request - user is blocked or has blocked you';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        // Refresh the friendship status to update UI
        widget.onRefreshFriendshipStatus?.call();
      }
    }
  }

  Future<void> _rejectFriendRequest() async {
    try {
      final friendsService = FriendsService();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Get the friend request ID
      final requestId = await friendsService.getFriendRequestId(
        widget.otherUserId,
        currentUserId,
      );

      if (requestId != null) {
        await friendsService.rejectFriendRequest(requestId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request declined'),
              backgroundColor: Colors.orange,
            ),
          );
          widget.onRefreshFriendshipStatus?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error declining friend request';
        if (e.toString().contains('blocked')) {
          errorMessage =
              'Cannot decline request - user is blocked or has blocked you';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        // Refresh the friendship status to update UI
        widget.onRefreshFriendshipStatus?.call();
      }
    }
  }
}
