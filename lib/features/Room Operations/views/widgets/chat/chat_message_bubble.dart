import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/widgets/base_message_bubble.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/chat_message.dart';

class ChatMessageBubble extends BaseMessageBubble<ChatMessage> {
  const ChatMessageBubble({
    super.key,
    required super.message,
    required super.isMyMessage,
    super.onDelete,
    super.onReply,
    super.onReact,
    super.onViewProfile,
  });

  @override
  bool get isSystemMessage => message.type == MessageType.system;

  @override
  String get messageContent => message.message;

  @override
  String get senderName => message.senderName ?? 'Unknown User';

  @override
  String get senderId => message.senderId;

  @override
  DateTime get timestamp => message.timestamp.toDate();

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
  Map<String, List<String>>? get reactions {
    if (message.reactions == null) return null;

    // Transform Map<String, dynamic> to Map<String, List<String>>
    final transformedReactions = <String, List<String>>{};
    message.reactions!.forEach((key, value) {
      if (value is List) {
        transformedReactions[key] = value.cast<String>();
      } else if (value is String) {
        transformedReactions[key] = [value];
      }
    });

    return transformedReactions;
  }

  @override
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}
