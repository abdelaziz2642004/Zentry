import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class BlockedUserCard extends StatelessWidget {
  final Map<String, dynamic> blockedUser;
  final VoidCallback onUnblock;

  const BlockedUserCard({
    super.key,
    required this.blockedUser,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final userName = blockedUser['fullName'] ?? 'Unknown User';
    final username = blockedUser['username'] ?? '';
    final imageUrl = blockedUser['imageUrl'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          backgroundColor: Colors.grey[400],
          child:
              imageUrl.isEmpty
                  ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  : null,
        ),
        title: Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '@$username',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: ElevatedButton(
          onPressed: () => _showUnblockDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Unblock'),
        ),
      ),
    );
  }

  void _showUnblockDialog(BuildContext context) {
    final userName = blockedUser['fullName'] ?? 'Unknown User';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unblock User'),
            content: Text(
              'Are you sure you want to unblock $userName? '
              'You will be able to send and receive messages from them again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onUnblock();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Unblock'),
              ),
            ],
          ),
    );
  }
}
