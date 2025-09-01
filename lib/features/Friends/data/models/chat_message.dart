import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, roomInvitation }

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;

  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  // For room invitations
  final String? roomCode;
  final String? roomName;
  final String? inviterName;

  // For reactions and replies
  final Map<String, List<String>>? reactions; // emoji -> list of user IDs
  final String? replyToMessageId;
  final String? replyToMessageContent;
  final String? replyToSenderName;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.roomCode,
    this.roomName,
    this.inviterName,
    this.reactions,
    this.replyToMessageId,
    this.replyToMessageContent,
    this.replyToSenderName,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${map['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp:
          map['timestamp'] != null
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
      isRead: map['isRead'] ?? false,
      roomCode: map['roomCode'],
      roomName: map['roomName'],
      inviterName: map['inviterName'],
      reactions:
          map['reactions'] != null
              ? Map<String, List<String>>.from(
                (map['reactions'] as Map<String, dynamic>).map(
                  (key, value) => MapEntry(key, List<String>.from(value)),
                ),
              )
              : null,
      replyToMessageId: map['replyToMessageId'],
      replyToMessageContent: map['replyToMessageContent'],
      replyToSenderName: map['replyToSenderName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,

      if (roomCode != null) 'roomCode': roomCode,
      if (roomName != null) 'roomName': roomName,
      if (inviterName != null) 'inviterName': inviterName,
      if (reactions != null) 'reactions': reactions,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      if (replyToMessageContent != null)
        'replyToMessageContent': replyToMessageContent,
      if (replyToSenderName != null) 'replyToSenderName': replyToSenderName,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? roomCode,
    String? roomName,
    String? inviterName,
    Map<String, List<String>>? reactions,
    String? replyToMessageId,
    String? replyToMessageContent,
    String? replyToSenderName,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      roomCode: roomCode ?? this.roomCode,
      roomName: roomName ?? this.roomName,
      inviterName: inviterName ?? this.inviterName,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessageContent:
          replyToMessageContent ?? this.replyToMessageContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
    );
  }
}
