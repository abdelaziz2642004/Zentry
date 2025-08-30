import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/screens/chat_screen.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationTile extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final UserService userService;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.userService,
  });

  @override
  Widget build(BuildContext context) {
    final userName = conversation['userName'] ?? 'Unknown';
    final lastMessage = conversation['lastMessage'] ?? '';
    final lastMessageTime = conversation['lastMessageTime'] as DateTime?;
    final unreadCount = conversation['unreadCount'] ?? 0;
    final userId = conversation['userId'] ?? '';
    final isOnline = conversation['isOnline'] ?? false;
    final lastSeen = conversation['lastSeen'] as DateTime?;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildUserAvatar(userId, userName),
        title: _buildUserName(userId, userName),
        subtitle: _buildSubtitle(lastMessage, unreadCount, isOnline, lastSeen),
        trailing: _buildUnreadBadge(unreadCount),
        onTap: () => _navigateToChat(context, userId, userName),
      ),
    );
  }

  Widget _buildUserAvatar(String userId, String userName) {
    return Stack(
      children: [
        StreamBuilder<String>(
          stream: userService.getUserImageUrlStream(userId),
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
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
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
        if (conversation['isOnline'] ?? false)
          Positioned(
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
          ),
      ],
    );
  }

  Widget _buildUserName(String userId, String userName) {
    return StreamBuilder<String>(
      stream: userService.getUserNameStream(userId),
      builder: (context, snapshot) {
        final displayName = snapshot.data ?? userName;
        return Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        );
      },
    );
  }

  Widget _buildSubtitle(
    String lastMessage,
    int unreadCount,
    bool isOnline,
    DateTime? lastSeen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
            fontSize: 14,
            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        _buildStatusIndicator(isOnline, lastSeen),
      ],
    );
  }

  Widget _buildStatusIndicator(bool isOnline, DateTime? lastSeen) {
    return Row(
      children: [
        if (isOnline) ...[
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Online',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else if (lastSeen != null) ...[
          Text(
            'Last seen ${_formatTime(lastSeen)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ] else ...[
          Text(
            'Offline',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildUnreadBadge(int unreadCount) {
    if (unreadCount <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(color: mainColor, shape: BoxShape.circle),
      child: Text(
        unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (_) => ChatCubit()..loadChatMessages(userId),
              child: ChatScreen(otherUserId: userId, otherUserName: userName),
            ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
