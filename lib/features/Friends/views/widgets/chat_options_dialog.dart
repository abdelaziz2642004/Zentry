import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatOptionsDialog extends StatelessWidget {
  final String otherUserId;
  final String otherUserName;
  final bool isBlocked;
  final bool isFriend;
  final bool isFriendRequestPending;
  final bool isAnyRequestPending;
  final VoidCallback onRefreshFriendshipStatus;

  const ChatOptionsDialog({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.isBlocked,
    required this.isFriend,
    required this.isFriendRequestPending,
    required this.isAnyRequestPending,
    required this.onRefreshFriendshipStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chat Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFriend && !isAnyRequestPending && !isBlocked)
            ListTile(
              leading: const Icon(Icons.person_add, color: mainColor),
              title: const Text('Send Friend Request'),
              onTap: () {
                Navigator.pop(context);
                _sendFriendRequest(context);
              },
            ),
          if (isFriendRequestPending)
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Friend Request Pending'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Friend request is pending'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          if (isFriend)
            ListTile(
              leading: const Icon(Icons.meeting_room, color: mainColor),
              title: const Text('Invite to Room'),
              onTap: () {
                Navigator.pop(context);
                _showRoomInvitationDialog(context);
              },
            ),
          if (isFriend)
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Remove Friend'),
              onTap: () {
                Navigator.pop(context);
                _removeFriend(context);
              },
            ),
          ListTile(
            leading: Icon(
              isBlocked ? Icons.block : Icons.block_outlined,
              color: isBlocked ? Colors.red : Colors.grey,
            ),
            title: Text(isBlocked ? 'Unblock User' : 'Block User'),
            onTap: () {
              Navigator.pop(context);
              _toggleBlockUser(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _sendFriendRequest(BuildContext context) async {
    try {
      final friendsService = FriendsService();
      await friendsService.sendFriendRequestById(
        receiverId: otherUserId,
        message: 'Hi! I\'d like to be your friend.',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend request sent!'),
            backgroundColor: Colors.green,
          ),
        );
        onRefreshFriendshipStatus();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending friend request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRoomInvitationDialog(BuildContext context) {
    final roomCodeController = TextEditingController();
    final roomNameController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Room Invitation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: roomCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Room Code',
                    hintText: 'Enter room code',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roomNameController,
                  decoration: const InputDecoration(
                    labelText: 'Room Name',
                    hintText: 'Enter room name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message (Optional)',
                    hintText: 'Add a personal message',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final roomCode = roomCodeController.text.trim();
                  final roomName = roomNameController.text.trim();

                  if (roomCode.isNotEmpty && roomName.isNotEmpty) {
                    Navigator.pop(context);
                    _sendRoomInvitation(
                      context,
                      roomCode,
                      roomName,
                      messageController.text.trim(),
                    );
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  void _sendRoomInvitation(
    BuildContext context,
    String roomCode,
    String roomName,
    String message,
  ) {
    final chatCubit = BlocProvider.of<ChatCubit>(context);
    chatCubit.sendRoomInvitation(
      receiverId: otherUserId,
      receiverName: otherUserName,
      roomCode: roomCode,
      roomName: roomName,
      message: message.isNotEmpty ? message : null,
    );
  }

  void _removeFriend(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Friend'),
            content: Text(
              'Are you sure you want to remove $otherUserName as a friend?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final friendsService = FriendsService();
        await friendsService.removeFriend(otherUserId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend removed'),
              backgroundColor: Colors.green,
            ),
          );
          onRefreshFriendshipStatus();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing friend: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _toggleBlockUser(BuildContext context) async {
    try {
      final blockService = BlockService();

      if (isBlocked) {
        await blockService.unblockUser(otherUserId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User unblocked'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await blockService.blockUser(otherUserId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User blocked'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      onRefreshFriendshipStatus();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
