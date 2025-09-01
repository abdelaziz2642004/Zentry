import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

class FriendRequestProfileSection extends StatelessWidget {
  final String senderId;
  final String senderName;
  final String senderUsername;
  final bool isBlocked;
  final bool isBlockedByUser;

  const FriendRequestProfileSection({
    super.key,
    required this.senderId,
    required this.senderName,
    required this.senderUsername,
    required this.isBlocked,
    required this.isBlockedByUser,
  });

  void _showProfilePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProfilePopupDialog(userId: senderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildProfileAvatar(context),
        const SizedBox(width: 12),
        Expanded(child: _buildUserInfo(context)),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final userService = UserService();
    return StreamBuilder<String>(
      stream: userService.getUserImageUrlStream(senderId),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;
        return GestureDetector(
          onTap: () => _showProfilePopup(context),
          child: CircleAvatar(
            radius: 25,
            backgroundImage:
                imageUrl?.isNotEmpty == true ? NetworkImage(imageUrl!) : null,
            backgroundColor: Colors.grey[400],
            child:
                imageUrl?.isEmpty != false
                    ? Text(
                      senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final userService = UserService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<String>(
          stream: userService.getUserNameStream(senderId),
          builder: (context, snapshot) {
            final displayName = snapshot.data ?? senderName;
            return GestureDetector(
              onTap: () => _showProfilePopup(context),
              child: Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
        Text(
          '@$senderUsername',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        if (isBlocked || isBlockedByUser) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isBlocked ? 'You blocked this user' : 'This user blocked you',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
