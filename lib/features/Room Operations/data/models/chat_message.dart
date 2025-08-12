import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, system, notification }

class ChatMessage {
  final String id;
  final String senderId;
  final String message;
  final Timestamp timestamp;
  final MessageType type;
  final String? senderName;
  final Map<String, dynamic>? reactions;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.type = MessageType.text,
    this.senderName,
    this.reactions,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      senderName: data['senderName'],
      reactions: data['reactions'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'message': message,
      'timestamp': timestamp,
      'type': type.toString().split('.').last,
      'senderName': senderName,
      'reactions': reactions,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? message,
    Timestamp? timestamp,
    MessageType? type,
    String? senderName,
    Map<String, dynamic>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      senderName: senderName ?? this.senderName,
      reactions: reactions ?? this.reactions,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderId: $senderId, message: $message, timestamp: $timestamp, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
