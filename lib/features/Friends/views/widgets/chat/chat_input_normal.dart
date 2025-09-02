import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class ChatInputNormal extends StatefulWidget {
  final TextEditingController messageController;
  final ChatMessage? replyingTo;
  final bool isSending;
  final VoidCallback? onClearReply;
  final VoidCallback? onSendMessage;

  const ChatInputNormal({
    super.key,
    required this.messageController,
    this.replyingTo,
    required this.isSending,
    this.onClearReply,
    this.onSendMessage,
  });

  @override
  State<ChatInputNormal> createState() => _ChatInputNormalState();
}

class _ChatInputNormalState extends State<ChatInputNormal> {
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_handleTextChanged);
    _handleTextChanged(); // Initialize the state
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final hasText = widget.messageController.text.trim().isNotEmpty;
    if (_isComposing != hasText) {
      setState(() {
        _isComposing = hasText;
      });
    }
  }

  void _handleSubmitted() {
    if (_isComposing && widget.onSendMessage != null) {
      widget.onSendMessage!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF05161A).withOpacity(0.9),
            const Color(0xFF072E33).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(color: const Color(0xFF2CACAD).withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          // Reply preview
          if (widget.replyingTo != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2CACAD).withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF2CACAD).withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2CACAD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${widget.replyingTo!.senderName}',
                          style: const TextStyle(
                            color: Color(0xFF2CACAD),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.replyingTo!.content,
                          style: TextStyle(
                            color: const Color(0xFFD9F5F0).withOpacity(0.8),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClearReply,
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: const Color(0xFFD9F5F0).withOpacity(0.7),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],

          // Message input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.messageController,
                    onSubmitted: (_) => _handleSubmitted(),
                    style: const TextStyle(color: Color(0xFFD9F5F0)),
                    decoration: InputDecoration(
                      hintText:
                          widget.replyingTo != null
                              ? 'Reply to message...'
                              : 'Type a message...',
                      hintStyle: TextStyle(
                        color: const Color(0xFFD9F5F0).withOpacity(0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2CACAD).withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color:
                        _isComposing && !widget.isSending
                            ? const Color(0xFF2CACAD)
                            : const Color(0xFF2CACAD).withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow:
                        _isComposing && !widget.isSending
                            ? [
                              BoxShadow(
                                color: const Color(0xFF2CACAD).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: IconButton(
                    onPressed:
                        _isComposing && !widget.isSending
                            ? _handleSubmitted
                            : null,
                    icon:
                        widget.isSending
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF05161A),
                                ),
                              ),
                            )
                            : Icon(
                              Icons.send,
                              color:
                                  _isComposing && !widget.isSending
                                      ? const Color(0xFF05161A)
                                      : const Color(
                                        0xFFD9F5F0,
                                      ).withOpacity(0.5),
                              size: 20,
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
