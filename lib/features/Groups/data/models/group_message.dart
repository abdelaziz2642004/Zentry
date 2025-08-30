import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupMessageType { text, system, notification }

class GroupMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String senderImageUrl;
  final String message;
  final Timestamp timestamp;
  final GroupMessageType messageType;
  final Map<String, dynamic>? reactions;

  // For replies
  final String? replyToMessageId;
  final String? replyToMessageContent;
  final String? replyToSenderName;

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.senderImageUrl,
    required this.message,
    required this.timestamp,
    this.messageType = GroupMessageType.text,
    this.reactions,
    this.replyToMessageId,
    this.replyToMessageContent,
    this.replyToSenderName,
  });

  factory GroupMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupMessage(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderImageUrl: data['senderImageUrl'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      messageType: GroupMessageType.values.firstWhere(
        (e) =>
            e.toString() == 'GroupMessageType.${data['messageType'] ?? 'text'}',
        orElse: () => GroupMessageType.text,
      ),
      reactions: data['reactions'],
      replyToMessageId: data['replyToMessageId'],
      replyToMessageContent: data['replyToMessageContent'],
      replyToSenderName: data['replyToSenderName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType.toString().split('.').last,
      'reactions': reactions,
      'replyToMessageId': replyToMessageId,
      'replyToMessageContent': replyToMessageContent,
      'replyToSenderName': replyToSenderName,
    };
  }

  GroupMessage copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? senderName,
    String? senderImageUrl,
    String? message,
    Timestamp? timestamp,
    GroupMessageType? messageType,
    Map<String, dynamic>? reactions,
    String? replyToMessageId,
    String? replyToMessageContent,
    String? replyToSenderName,
  }) {
    return GroupMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessageContent:
          replyToMessageContent ?? this.replyToMessageContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
    );
  }

  @override
  String toString() {
    return 'GroupMessage(id: $id, groupId: $groupId, senderId: $senderId, message: $message, timestamp: $timestamp, messageType: $messageType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
