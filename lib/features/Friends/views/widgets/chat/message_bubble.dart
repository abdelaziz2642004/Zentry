import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/widgets/base_message_bubble.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';

class MessageBubble extends BaseMessageBubble<ChatMessage> {
  final bool isBlocked;
  final bool isBlockedByUser;
  final bool isFriend;
  final bool isAnyRequestPending;

  const MessageBubble({
    super.key,
    required super.message,
    required super.isMyMessage,
    super.onDelete,
    super.onReply,
    super.onReact,
    super.onViewProfile,
    this.isBlocked = false,
    this.isBlockedByUser = false,
    this.isFriend = true,
    this.isAnyRequestPending = false,
  });

  @override
  bool get isSystemMessage => false; // ChatMessage doesn't have system messages

  @override
  String get messageContent => message.content;

  @override
  String get senderName => message.senderName;

  @override
  String get senderId => message.senderId;

  @override
  DateTime get timestamp => message.timestamp;

  @override
  ReplyInfo? get replyInfo {
    if (message.replyToMessageId == null) return null;
    return ReplyInfo(
      replyToMessageId: message.replyToMessageId,
      replyToMessageContent: message.replyToMessageContent,
      replyToSenderName: message.replyToSenderName,
    );
  }

  @override
  Map<String, List<String>>? get reactions => message.reactions;

  @override
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  bool canInteractWithMessage() {
    return isFriend && !isBlocked && !isBlockedByUser && !isAnyRequestPending;
  }
}
