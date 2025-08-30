import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

class FriendProfileSection extends StatelessWidget {
  final String friendId;
  final String fullName;
  final String username;
  final bool isOnline;

  const FriendProfileSection({
    super.key,
    required this.friendId,
    required this.fullName,
    required this.username,
    required this.isOnline,
  });

  void _showProfilePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProfilePopupDialog(userId: friendId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return Row(
      children: [
        _buildProfileAvatar(context, userService),
        const SizedBox(width: 12),
        Expanded(child: _buildUserInfo(context, userService)),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context, UserService userService) {
    return StreamBuilder<String>(
      stream: userService.getUserImageUrlStream(friendId),
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
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
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

  Widget _buildUserInfo(BuildContext context, UserService userService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<String>(
          stream: userService.getUserNameStream(friendId),
          builder: (context, snapshot) {
            final displayName = snapshot.data ?? fullName;
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
          '@$username',
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
                color: isOnline ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
