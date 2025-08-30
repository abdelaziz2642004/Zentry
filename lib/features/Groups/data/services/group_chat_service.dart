import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/group_message.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class GroupChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get messages for a group (real-time stream like room chat)
  Stream<List<GroupMessage>> getGroupMessages(String groupId) {
    return _firestore
        .collection('studyGroups')
        .doc(groupId)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .limit(50) // Load last 50 messages
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => GroupMessage.fromFirestore(doc))
                  .toList()
                  .reversed
                  .toList(),
        ); // Reverse to show oldest first
  }

  /// Get group members with their profile images (real-time stream)
  Stream<List<Map<String, dynamic>>> getGroupMembers(String groupId) {
    return _firestore
        .collection('studyGroups')
        .doc(groupId)
        .snapshots()
        .asyncMap((groupSnapshot) async {
          if (!groupSnapshot.exists) return [];

          final groupData = groupSnapshot.data()!;
          final memberIds = List<String>.from(groupData['memberIds'] ?? []);

          final members = <Map<String, dynamic>>[];
          for (final memberId in memberIds) {
            final userDoc =
                await _firestore
                    .collection(FirebaseConstants.usersCollection)
                    .doc(memberId)
                    .get();

            if (userDoc.exists) {
              final userData = userDoc.data()!;
              members.add({
                'id': memberId,
                'name': userData[FirebaseConstants.fullNameField],
                'imageUrl': userData[FirebaseConstants.imageUrlField] ?? '',
                'isAdmin':
                    (groupData['adminIds'] as List<dynamic>?)?.contains(
                      memberId,
                    ) ??
                    false,
              });
            }
          }

          return members;
        });
  }

  /// Send a message to a group
  Future<void> sendMessage({
    required String groupId,
    required String message,
    GroupMessageType messageType = GroupMessageType.text,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Get current user data
    final currentUserDoc =
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid)
            .get();

    if (!currentUserDoc.exists) {
      throw Exception('Current user data not found');
    }

    final currentUserData = currentUserDoc.data()!;

    // Create the message
    final groupMessage = GroupMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: groupId,
      senderId: currentUser.uid,
      senderName: currentUserData[FirebaseConstants.fullNameField],
      senderImageUrl: currentUserData[FirebaseConstants.imageUrlField] ?? '',
      message: message,
      timestamp: Timestamp.now(),
      messageType: messageType,
    );

    // Add message to group chat subcollection
    await _firestore
        .collection('studyGroups')
        .doc(groupId)
        .collection('chat')
        .add(groupMessage.toFirestore());

    // Update group's last activity
    await _firestore.collection('studyGroups').doc(groupId).update({
      'lastActivity': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a message
  Future<void> deleteMessage(String groupId, String messageId) async {
    await _firestore
        .collection('studyGroups')
        .doc(groupId)
        .collection('chat')
        .doc(messageId)
        .delete();
  }

  /// Update message reactions
  Future<void> updateMessageReactions(
    String groupId,
    String messageId,
    Map<String, List<String>> reactions,
  ) async {
    await _firestore
        .collection('studyGroups')
        .doc(groupId)
        .collection('chat')
        .doc(messageId)
        .update({'reactions': reactions});
  }

  /// Send a reply message
  Future<void> sendReplyMessage({
    required String groupId,
    required String message,
    required String replyToMessageId,
    required String replyToMessageContent,
    required String replyToSenderName,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Get current user data
    final currentUserDoc =
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid)
            .get();

    if (!currentUserDoc.exists) {
      throw Exception('Current user data not found');
    }

    final currentUserData = currentUserDoc.data()!;

    // Create the reply message
    final groupMessage = GroupMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: groupId,
      senderId: currentUser.uid,
      senderName: currentUserData[FirebaseConstants.fullNameField],
      senderImageUrl: currentUserData[FirebaseConstants.imageUrlField] ?? '',
      message: message,
      timestamp: Timestamp.now(),
      messageType: GroupMessageType.text,
      replyToMessageId: replyToMessageId,
      replyToMessageContent: replyToMessageContent,
      replyToSenderName: replyToSenderName,
    );

    // Add message to group chat subcollection
    await _firestore
        .collection('studyGroups')
        .doc(groupId)
        .collection('chat')
        .add(groupMessage.toFirestore());

    // Update group's last activity
    await _firestore.collection('studyGroups').doc(groupId).update({
      'lastActivity': FieldValue.serverTimestamp(),
    });
  }
}
