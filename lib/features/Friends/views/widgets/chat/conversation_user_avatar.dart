import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/conversation_utils.dart';

class ConversationUserAvatar extends StatelessWidget {
  final String userId;
  final String userName;
  final bool isOnline;
  final double radius;

  const ConversationUserAvatar({
    super.key,
    required this.userId,
    required this.userName,
    required this.isOnline,
    this.radius = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [_buildAvatar(), if (isOnline) _buildOnlineIndicator()],
    );
  }

  Widget _buildAvatar() {
    return StreamBuilder<String>(
      stream: UserService().getUserImageUrlStream(userId),
      builder: (context, snapshot) {
        String? imageUrl = snapshot.data;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading error silently
            },
          );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[400],
            child: Text(
              ConversationUtils.getUserInitials(userName),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildOnlineIndicator() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
