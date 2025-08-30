import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/friend_request.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class FriendRequestCard extends StatefulWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FriendRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<FriendRequestCard> createState() => _FriendRequestCardState();
}

class _FriendRequestCardState extends State<FriendRequestCard> {
  final BlockService _blockService = BlockService();
  final UserService _userService = UserService();
  bool _isBlocked = false;
  bool _isBlockedByUser = false;

  @override
  void initState() {
    super.initState();
    _checkBlockStatus();
  }

  Future<void> _checkBlockStatus() async {
    try {
      final isBlocked = await _blockService.isUserBlocked(
        widget.request.senderId,
      );
      final isBlockedByUser = await _blockService.isBlockedByUser(
        widget.request.senderId,
      );

      if (mounted) {
        setState(() {
          _isBlocked = isBlocked;
          _isBlockedByUser = isBlockedByUser;
        });
      }
    } catch (e) {
      print('Error checking block status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = _isBlocked || _isBlockedByUser;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StreamBuilder<String>(
                  stream: _userService.getUserImageUrlStream(
                    widget.request.senderId,
                  ),
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
                          widget.request.senderName.isNotEmpty
                              ? widget.request.senderName[0].toUpperCase()
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<String>(
                        stream: _userService.getUserNameStream(
                          widget.request.senderId,
                        ),
                        builder: (context, snapshot) {
                          final displayName =
                              snapshot.data ?? widget.request.senderName;
                          return Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                      Text(
                        '@${widget.request.senderUsername}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      if (isBlocked) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isBlocked
                                ? 'You blocked this user'
                                : 'This user blocked you',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.request.message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.request.message,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isBlocked ? null : widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isBlocked ? 'Blocked' : 'Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
