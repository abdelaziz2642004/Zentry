import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/friend.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friends_list/friend_profile_section.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friends_list/friend_action_buttons.dart';

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

  Future<void> _handleBlockAction() async {
    try {
      if (_isBlocked) {
        await _blockService.unblockUser(widget.friend.id);
        setState(() {
          _isBlocked = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.friend.fullName} has been unblocked'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _blockService.blockUser(widget.friend.id);
        setState(() {
          _isBlocked = true;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.friend.fullName} has been blocked'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      widget.onBlock?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${_isBlocked ? 'unblocking' : 'blocking'} user: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: FriendProfileSection(
                friendId: widget.friend.id,
                fullName: widget.friend.fullName,
                username: widget.friend.username,
                isOnline: widget.friend.isOnline,
              ),
            ),
            FriendActionButtons(
              friendId: widget.friend.id,
              friendName: widget.friend.fullName,
              isBlocked: _isBlocked,
              onRemove: widget.onRemove,
              onBlock: _handleBlockAction,
            ),
          ],
        ),
      ),
    );
  }
}
