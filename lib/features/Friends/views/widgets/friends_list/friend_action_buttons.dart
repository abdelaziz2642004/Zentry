import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/screens/chat_screen.dart';

class FriendActionButtons extends StatelessWidget {
  final String friendId;
  final String friendName;
  final bool isBlocked;
  final VoidCallback onRemove;
  final VoidCallback? onBlock;

  const FriendActionButtons({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.isBlocked,
    required this.onRemove,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isBlocked) ...[
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BlocProvider(
                        create: (_) => ChatCubit(),
                        child: ChatScreen(
                          otherUserId: friendId,
                          otherUserName: friendName,
                        ),
                      ),
                ),
              );
            },
          ),
        ],
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'remove') {
              onRemove();
            } else if (value == 'block') {
              await _showBlockDialog(context);
            } else if (value == 'unblock') {
              await _showUnblockDialog(context);
            }
          },
          itemBuilder:
              (context) => [
                if (!isBlocked) ...[
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove Friend'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Block User'),
                      ],
                    ),
                  ),
                ] else ...[
                  const PopupMenuItem(
                    value: 'unblock',
                    child: Row(
                      children: [
                        Icon(Icons.block_outlined, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Unblock User'),
                      ],
                    ),
                  ),
                ],
              ],
        ),
      ],
    );
  }

  Future<void> _showBlockDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block User'),
          content: Text(
            'Are you sure you want to block $friendName? '
            'You won\'t be able to send or receive messages from them.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onBlock?.call();
    }
  }

  Future<void> _showUnblockDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unblock User'),
          content: Text(
            'Are you sure you want to unblock $friendName? '
            'You will be able to send and receive messages from them again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Unblock'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onBlock?.call();
    }
  }
}
