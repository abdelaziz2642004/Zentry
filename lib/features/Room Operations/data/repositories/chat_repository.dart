import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to chat messages
  Stream<List<ChatMessage>> listenToChat(String roomCode) {
    return _firestore
        .collection('Rooms')
        .doc(roomCode)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .limit(50) // Load last 50 messages
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessage.fromFirestore(doc))
                  .toList()
                  .reversed
                  .toList(),
        ); // Reverse to show oldest first
  }

  // Send message
  Future<void> sendMessage(String roomCode, ChatMessage message) async {
    await _firestore
        .collection('Rooms')
        .doc(roomCode)
        .collection('chat')
        .add(message.toFirestore());
  }

  // Send system message (user joined/left)
  Future<void> sendSystemMessage(String roomCode, String message) async {
    final systemMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'system',
      message: message,
      timestamp: Timestamp.now(),
      type: MessageType.system,
    );

    await sendMessage(roomCode, systemMessage);
  }

  // Delete message (for message sender or room creator)
  Future<void> deleteMessage(String roomCode, String messageId) async {
    await _firestore
        .collection('Rooms')
        .doc(roomCode)
        .collection('chat')
        .doc(messageId)
        .delete();
  }

  // Update message reactions (future feature)
  Future<void> updateMessageReactions(
    String roomCode,
    String messageId,
    Map<String, dynamic> reactions,
  ) async {
    await _firestore
        .collection('Rooms')
        .doc(roomCode)
        .collection('chat')
        .doc(messageId)
        .update({'reactions': reactions});
  }
}
