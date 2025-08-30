import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
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
  final FriendsService _friendsService = FriendsService();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Friend request received from ${widget.otherUserName}',
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Reply preview
          if (widget.replyingTo != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: mainColor,
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
                          style: TextStyle(
                            color: mainColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.replyingTo!.content,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Clear reply - this would need to be handled by parent
                      // For now, we'll just close the reply UI
                      widget.onClearReply?.call();
                    },
                    icon: const Icon(Icons.close, size: 20),
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
                    decoration: InputDecoration(
                      hintText:
                          widget.replyingTo != null
                              ? 'Reply to message...'
                              : 'Type a message...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
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
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final chatCubit = BlocProvider.of<ChatCubit>(context);

      if (widget.replyingTo != null) {
        // Send reply message
        chatCubit.sendReplyMessage(
          receiverId: widget.otherUserId,
          receiverName: widget.otherUserName,
          content: message,
          replyToMessageId: widget.replyingTo!.id,
          replyToMessageContent: widget.replyingTo!.content,
          replyToSenderName: widget.replyingTo!.senderName,
        );
      } else {
        // Send normal message
        chatCubit.sendMessage(
          receiverId: widget.otherUserId,
          receiverName: widget.otherUserName,
          content: message,
        );
      }

      _messageController.clear();
      // Clear reply state after sending
      widget.onClearReply?.call();
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

  Future<void> _acceptFriendRequest() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Find the existing request ID
      final requestId = await _friendsService.getFriendRequestId(
        widget.otherUserId,
        currentUserId,
      );

      if (requestId != null) {
        // Accept the existing request
        await _friendsService.acceptFriendRequest(requestId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request accepted!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh friendship status
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting friend request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectFriendRequest() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Find the existing request ID
      final requestId = await _friendsService.getFriendRequestId(
        widget.otherUserId,
        currentUserId,
      );

      if (requestId != null) {
        // Reject the existing request
        await _friendsService.rejectFriendRequest(requestId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend request declined'),
              backgroundColor: Colors.orange,
            ),
          );
          // Refresh friendship status
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining friend request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendFriendRequest() async {
    try {
      await _friendsService.sendFriendRequestById(
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
}
