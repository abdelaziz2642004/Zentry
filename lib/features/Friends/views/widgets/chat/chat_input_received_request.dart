import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/chat_input_utils.dart';

class ChatInputReceivedRequest extends StatelessWidget {
  final String otherUserName;
  final bool isAccepting;
  final bool isRejecting;
  final bool isRefreshing;
  final VoidCallback? onAcceptRequest;
  final VoidCallback? onRejectRequest;

  const ChatInputReceivedRequest({
    super.key,
    required this.otherUserName,
    required this.isAccepting,
    required this.isRejecting,
    this.isRefreshing = false,
    this.onAcceptRequest,
    this.onRejectRequest,
  });

  @override
  Widget build(BuildContext context) {
    final inputType = ChatInputType.receivedRequest;
    final backgroundColor = ChatInputUtils.getBackgroundColor(inputType, false);
    final borderColor = ChatInputUtils.getBorderColor(inputType, false);
    final iconColor = ChatInputUtils.getInputColor(inputType);
    final title = ChatInputUtils.getInputTitle(inputType, otherUserName);
    final isLoading = isAccepting || isRejecting || isRefreshing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: iconColor, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onAcceptRequest,
                  icon:
                      isAccepting
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
                          : const Icon(Icons.check, size: 18),
                  label: Text(isAccepting ? 'Accepting...' : 'Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onRejectRequest,
                  icon:
                      isRejecting
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
                          : const Icon(Icons.close, size: 18),
                  label: Text(isRejecting ? 'Declining...' : 'Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
