import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/user_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/screens/chat_screen.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/conversation_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/conversation_user_avatar.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/conversation_user_name.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/conversation_status_indicator.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/chat/conversation_unread_badge.dart';
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
    if (!ConversationUtils.isValidConversation(conversation)) {
      return const SizedBox.shrink();
    }

    final userName = ConversationUtils.getConversationDisplayName(conversation);
    final lastMessage = ConversationUtils.getConversationLastMessage(
      conversation,
    );
    final unreadCount = ConversationUtils.getConversationUnreadCount(
      conversation,
    );
    final userId = ConversationUtils.getConversationUserId(conversation);
    final isOnline = ConversationUtils.getConversationOnlineStatus(
      conversation,
    );
    final lastSeen = ConversationUtils.getConversationLastSeen(conversation);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ListTile(
        leading: ConversationUserAvatar(
          userId: userId,
          userName: userName,
          isOnline: isOnline,
        ),
        title: ConversationUserName(userId: userId, fallbackName: userName),
        subtitle: _buildSubtitle(lastMessage, unreadCount, isOnline, lastSeen),
        trailing: ConversationUnreadBadge(conversation: conversation),
        onTap: () => _navigateToChat(context, userId, userName),
      ),
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
          style: ConversationUtils.getSubtitleTextStyle(unreadCount),
        ),
        const SizedBox(height: 4),
        ConversationStatusIndicator(isOnline: isOnline, lastSeen: lastSeen),
      ],
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
}
