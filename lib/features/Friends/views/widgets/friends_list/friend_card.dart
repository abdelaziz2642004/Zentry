import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/friend.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/screens/chat_screen.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class FriendCard extends StatefulWidget {
  final Friend friend;
  final VoidCallback onRemove;
  final VoidCallback? onBlock;

  const FriendCard({
    super.key,
    required this.friend,
    required this.onRemove,
    this.onBlock,
  });

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {
  final BlockService _blockService = BlockService();
  final UserService _userService = UserService();
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _checkBlockStatus();
  }

  Future<void> _checkBlockStatus() async {
    try {
      final isBlocked = await _blockService.isUserBlocked(widget.friend.id);
      if (mounted) {
        setState(() {
          _isBlocked = isBlocked;
        });
      }
    } catch (e) {
      print('Error checking block status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: StreamBuilder<String>(
          stream: _userService.getUserImageUrlStream(widget.friend.id),
          builder: (context, snapshot) {
            String? imageUrl = snapshot.data;

            if (imageUrl != null && imageUrl.isNotEmpty) {
              return CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(imageUrl),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image loading error
                },
              );
            } else {
              return CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[400],
                child: Text(
                  widget.friend.fullName.isNotEmpty
                      ? widget.friend.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            }
          },
        ),
        title: StreamBuilder<String>(
          stream: _userService.getUserNameStream(widget.friend.id),
          builder: (context, snapshot) {
            final displayName = snapshot.data ?? widget.friend.fullName;
            return Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            );
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '@${widget.friend.username}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.friend.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.friend.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: widget.friend.isOnline ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isBlocked) ...[
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
                              otherUserId: widget.friend.id,
                              otherUserName: widget.friend.fullName,
                            ),
                          ),
                    ),
                  );
                },
              ),
            ],
            PopupMenuButton<String>(
              onSelected: (value) async {
                print('Popup menu selected: $value'); // Debug print
                if (value == 'remove') {
                  widget.onRemove();
                } else if (value == 'block') {
                  print('Block option selected'); // Debug print
                  await _showBlockDialog(context);
                } else if (value == 'unblock') {
                  print('Unblock option selected'); // Debug print
                  await _showUnblockDialog(context);
                }
              },
              itemBuilder:
                  (context) => [
                    if (!_isBlocked) ...[
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
        ),
      ),
    );
  }

  Future<void> _showBlockDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block User'),
          content: Text(
            'Are you sure you want to block ${widget.friend.fullName}? '
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
      try {
        await _blockService.blockUser(widget.friend.id);
        setState(() {
          _isBlocked = true;
        });
        widget.onBlock?.call();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.friend.fullName} has been blocked'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error blocking user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showUnblockDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unblock User'),
          content: Text(
            'Are you sure you want to unblock ${widget.friend.fullName}? '
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
      try {
        await _blockService.unblockUser(widget.friend.id);
        setState(() {
          _isBlocked = false;
        });
        widget.onBlock?.call();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.friend.fullName} has been unblocked'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error unblocking user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
