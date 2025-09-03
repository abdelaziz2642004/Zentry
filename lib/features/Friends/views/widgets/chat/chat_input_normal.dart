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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2CACAD).withOpacity(0.15),
                          const Color(0xFF0F9E9C).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            _isComposing
                                ? const Color(0xFF2CACAD).withOpacity(0.5)
                                : const Color(0xFF2CACAD).withOpacity(0.3),
                        width: _isComposing ? 1.5 : 1,
                      ),
                      boxShadow: [
                        if (_isComposing)
                          BoxShadow(
                            color: const Color(0xFF2CACAD).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: TextField(
                      controller: widget.messageController,
                      onSubmitted: (_) => _handleSubmitted(),
                      style: const TextStyle(
                        color: Color(0xFFD9F5F0),
                        fontSize: 15,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            widget.replyingTo != null
                                ? '💬 Reply to message...'
                                : '💭 Type a message...',
                        hintStyle: TextStyle(
                          color: const Color(0xFFD9F5F0).withOpacity(0.6),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        prefixIcon:
                            _isComposing
                                ? Icon(
                                  Icons.edit_outlined,
                                  color: const Color(
                                    0xFF2CACAD,
                                  ).withOpacity(0.7),
                                  size: 20,
                                )
                                : null,
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  tween: Tween(
                    begin: 0.0,
                    end: _isComposing && !widget.isSending ? 1.0 : 0.0,
                  ),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * value),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient:
                              _isComposing && !widget.isSending
                                  ? LinearGradient(
                                    colors: [
                                      const Color(0xFF2CACAD),
                                      const Color(0xFF0F9E9C),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : LinearGradient(
                                    colors: [
                                      const Color(0xFF2CACAD).withOpacity(0.3),
                                      const Color(0xFF0F9E9C).withOpacity(0.2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          shape: BoxShape.circle,
                          boxShadow:
                              _isComposing && !widget.isSending
                                  ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2CACAD,
                                      ).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFF0F9E9C,
                                      ).withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2CACAD,
                                      ).withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap:
                                _isComposing && !widget.isSending
                                    ? _handleSubmitted
                                    : null,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child:
                                  widget.isSending
                                      ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF05161A),
                                                ),
                                          ),
                                        ),
                                      )
                                      : Icon(
                                        Icons.send_rounded,
                                        color:
                                            _isComposing && !widget.isSending
                                                ? const Color(0xFF05161A)
                                                : const Color(
                                                  0xFFD9F5F0,
                                                ).withOpacity(0.5),
                                        size: 22,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
