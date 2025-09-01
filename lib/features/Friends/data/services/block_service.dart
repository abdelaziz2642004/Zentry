import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class BlockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Block a user
  Future<void> blockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    print('Attempting to block user: $blockedUserId'); // Debug print

    if (currentUser.uid == blockedUserId) {
      throw Exception('Cannot block yourself');
    }

    try {
      // Add to blocked users list
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('blockedUsers')
          .doc(blockedUserId)
          .set({
            'blockedAt': FieldValue.serverTimestamp(),
            'blockedUserId': blockedUserId,
          });

      print('User $blockedUserId added to blocked users list'); // Debug print

      // Remove from friends list if they were friends
      await _removeFromFriendsIfNeeded(currentUser.uid, blockedUserId);

      // Auto-decline any pending friend requests between the users
      await _declineFriendRequests(currentUser.uid, blockedUserId);

      print('User $blockedUserId successfully blocked'); // Debug print
    } catch (e) {
      print('Error blocking user $blockedUserId: $e'); // Debug print
      rethrow;
    }
  }

  /// Unblock a user
  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  /// Get list of blocked users
  Stream<List<String>> getBlockedUsers() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final doc =
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('blockedUsers')
            .doc(userId)
            .get();

    return doc.exists;
  }

  /// Stream to check if a user is blocked (real-time)
  Stream<bool> isUserBlockedStream(String userId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blockedUsers')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Check if current user is blocked by another user
  Future<bool> isBlockedByUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('blockedUsers')
            .doc(currentUser.uid)
            .get();

    return doc.exists;
  }

  /// Stream to check if current user is blocked by another user (real-time)
  Stream<bool> isBlockedByUserStream(String userId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Check if two users can interact (neither has blocked the other)
  Future<bool> canUsersInteract(String userId1, String userId2) async {
    final isUser1Blocked = await isUserBlocked(userId2);
    final isUser2Blocked = await isBlockedByUser(userId2);

    return !isUser1Blocked && !isUser2Blocked;
  }

  /// Stream to check if two users can interact (real-time)
  Stream<bool> canUsersInteractStream(String userId1, String userId2) {
    return _firestore
        .collection('users')
        .doc(userId1)
        .collection('blockedUsers')
        .doc(userId2)
        .snapshots()
        .asyncMap((doc1) async {
          final doc2 =
              await _firestore
                  .collection('users')
                  .doc(userId2)
                  .collection('blockedUsers')
                  .doc(userId1)
                  .get();
          return !doc1.exists && !doc2.exists;
        });
  }

  /// Remove user from friends list if they were friends
  Future<void> _removeFromFriendsIfNeeded(
    String userId1,
    String userId2,
  ) async {
    try {
      // Check if they were friends
      final friendDoc1 =
          await _firestore
              .collection('friends')
              .doc(userId1)
              .collection('friendsList')
              .doc(userId2)
              .get();

      final friendDoc2 =
          await _firestore
              .collection('friends')
              .doc(userId2)
              .collection('friendsList')
              .doc(userId1)
              .get();

      // If they were friends, remove from both friends lists
      if (friendDoc1.exists && friendDoc2.exists) {
        await _firestore
            .collection('friends')
            .doc(userId1)
            .collection('friendsList')
            .doc(userId2)
            .delete();

        await _firestore
            .collection('friends')
            .doc(userId2)
            .collection('friendsList')
            .doc(userId1)
            .delete();
      }
    } catch (e) {
      print('Error removing from friends list: $e');
    }
  }

  /// Decline all pending friend requests between two users
  Future<void> _declineFriendRequests(String userId1, String userId2) async {
    try {
      // Find all pending friend requests between these users
      final requestsQuery =
          await _firestore
              .collection('friendRequests')
              .where('status', isEqualTo: 'pending')
              .get();

      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (final doc in requestsQuery.docs) {
        final data = doc.data();
        final senderId = data['senderId'];
        final receiverId = data['receiverId'];

        // Check if this request is between the two users (in either direction)
        if ((senderId == userId1 && receiverId == userId2) ||
            (senderId == userId2 && receiverId == userId1)) {
          batch.update(doc.reference, {
            'status': 'rejected',
            'respondedAt': FieldValue.serverTimestamp(),
            'autoDeclined': true, // Mark as auto-declined
          });
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
        print('Auto-declined friend requests between $userId1 and $userId2');
      }
    } catch (e) {
      print('Error auto-declining friend requests: $e');
    }
  }
}
