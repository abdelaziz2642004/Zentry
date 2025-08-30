import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';

class ChatOptionsDialog extends StatelessWidget {
  final String otherUserId;
  final bool isBlocked;
  final VoidCallback onRefreshFriendshipStatus;

  const ChatOptionsDialog({
    super.key,
    required this.otherUserId,
    required this.isBlocked,
    required this.onRefreshFriendshipStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chat Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
