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

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF05161A).withOpacity(0.9),
                    const Color(0xFF072E33).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      unreadCount > 0
                          ? const Color(0xFF2CACAD).withOpacity(0.6)
                          : const Color(0xFF2CACAD).withOpacity(0.3),
                  width: unreadCount > 0 ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        unreadCount > 0
                            ? const Color(0xFF2CACAD).withOpacity(0.25)
                            : const Color(0xFF2CACAD).withOpacity(0.15),
                    blurRadius: unreadCount > 0 ? 12 : 8,
                    spreadRadius: unreadCount > 0 ? 2 : 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToChat(context, userId, userName),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Enhanced avatar with better online status
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isOnline
                                          ? const Color(0xFF2CACAD)
                                          : const Color(
                                            0xFF2CACAD,
                                          ).withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  if (isOnline)
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2CACAD,
                                      ).withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(
                                  0xFF2CACAD,
                                ).withOpacity(0.2),
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2CACAD),
                                  ),
                                ),
                              ),
                            ),

                            // Online status with pulsing animation for online users
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child:
                                  isOnline
                                      ? TweenAnimationBuilder<double>(
                                        duration: const Duration(
                                          milliseconds: 2000,
                                        ),
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        builder: (context, pulseValue, child) {
                                          return Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0F9E9C),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF05161A),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF0F9E9C,
                                                  ).withOpacity(0.6),
                                                  blurRadius:
                                                      4 + (2 * pulseValue),
                                                  spreadRadius: 1 + pulseValue,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                      : Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF072E33),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF05161A),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Message content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            unreadCount > 0
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                        color: const Color(0xFFD9F5F0),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  if (lastSeen != null)
                                    Text(
                                      _formatTime(lastSeen!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(
                                          0xFF2CACAD,
                                        ).withOpacity(0.7),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            unreadCount > 0
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color:
                                            unreadCount > 0
                                                ? const Color(
                                                  0xFFD9F5F0,
                                                ).withOpacity(0.9)
                                                : const Color(
                                                  0xFFD9F5F0,
                                                ).withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  if (unreadCount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF2CACAD),
                                            const Color(0xFF0F9E9C),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF2CACAD,
                                            ).withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : unreadCount.toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF05161A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              ConversationStatusIndicator(
                                isOnline: isOnline,
                                lastSeen: lastSeen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
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
