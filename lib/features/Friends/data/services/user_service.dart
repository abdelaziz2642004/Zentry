import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a stream of user data by user ID
  /// This will automatically update when the user's data changes in Firestore
  Stream<Map<String, dynamic>?> getUserStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  /// Get user data once (not a stream)
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc =
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(userId)
            .get();
    return doc.exists ? doc.data() : null;
  }

  /// Get multiple users' data as streams
  Stream<Map<String, Map<String, dynamic>>> getMultipleUsersStream(
    List<String> userIds,
  ) {
    if (userIds.isEmpty) return Stream.value({});

    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .where(FieldPath.documentId, whereIn: userIds)
        .snapshots()
        .map((snapshot) {
          final users = <String, Map<String, dynamic>>{};
          for (final doc in snapshot.docs) {
            users[doc.id] = doc.data();
          }
          return users;
        });
  }

  /// Get user's image URL stream
  Stream<String> getUserImageUrlStream(String userId) {
    return getUserStream(userId).map((userData) {
      return userData?[FirebaseConstants.imageUrlField] ?? '';
    });
  }

  /// Get user's name stream
  Stream<String> getUserNameStream(String userId) {
    return getUserStream(userId).map((userData) {
      return userData?[FirebaseConstants.fullNameField] ?? '';
    });
  }

  /// Get user's online status stream
  Stream<bool> getUserOnlineStatusStream(String userId) {
    return getUserStream(userId).map((userData) {
      return userData?['isOnline'] ?? false;
    });
  }
}
