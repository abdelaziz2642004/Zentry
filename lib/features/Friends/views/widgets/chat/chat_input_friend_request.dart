import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/chat_input_utils.dart';

class ChatInputFriendRequest extends StatelessWidget {
  final String otherUserName;
  final bool isFriendRequestPending;
  final bool isAnyRequestPending;
  final bool isLoading;
  final bool isRefreshing;
  final VoidCallback? onSendFriendRequest;
  final VoidCallback? onRefreshFriendshipStatus;

  const ChatInputFriendRequest({
    super.key,
    required this.otherUserName,
    required this.isFriendRequestPending,
    required this.isAnyRequestPending,
    required this.isLoading,
    this.isRefreshing = false,
    this.onSendFriendRequest,
    this.onRefreshFriendshipStatus,
  });

  @override
  Widget build(BuildContext context) {
    final inputType =
        isAnyRequestPending
            ? ChatInputType.anyRequestPending
            : ChatInputType.friendRequest;

    final backgroundColor = ChatInputUtils.getBackgroundColor(
      inputType,
      isFriendRequestPending,
    );
    final borderColor = ChatInputUtils.getBorderColor(
      inputType,
      isFriendRequestPending,
    );
    final iconColor = ChatInputUtils.getInputColor(inputType);
    final subtitle = ChatInputUtils.getInputSubtitle(
      inputType,
      isFriendRequestPending,
    );
    final icon = ChatInputUtils.getInputIcon(inputType, isFriendRequestPending);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(color: iconColor, fontSize: 14),
                ),
              ),
            ],
          ),
          if (!isFriendRequestPending && !isAnyRequestPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    (isLoading || isRefreshing) ? null : onSendFriendRequest,
                icon:
                    (isLoading || isRefreshing)
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.person_add, size: 18),
                label: Text(
                  (isLoading || isRefreshing)
                      ? 'Sending...'
                      : 'Send Friend Request',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
