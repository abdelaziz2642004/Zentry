import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/friend_request.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friend_requests/friend_request_profile_section.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friend_requests/friend_request_action_buttons.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friend_requests/friend_request_message.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF05161A).withOpacity(0.8),
            const Color(0xFF072E33).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2CACAD).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2CACAD).withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FriendRequestProfileSection(
              senderId: widget.request.senderId,
              senderName: widget.request.senderName,
              senderUsername: widget.request.senderUsername,
              isBlocked: _isBlocked,
              isBlockedByUser: _isBlockedByUser,
            ),
            FriendRequestMessage(message: widget.request.message),
            const SizedBox(height: 16),
            FriendRequestActionButtons(
              onAccept: widget.onAccept,
              onReject: widget.onReject,
              isBlocked: isBlocked,
            ),
          ],
        ),
      ),
    );
  }
}
