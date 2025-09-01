import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';

class FriendshipChecker {
  final FriendsService _friendsService = FriendsService();

  /// Checks if two users are already friends
  Future<bool> checkIfFriends(String userId1, String userId2) async {
    try {
      return await _friendsService.checkIfFriends(userId1, userId2);
    } catch (e) {
      print('Error checking friendship status: $e');
      return false;
    }
  }

  /// Checks if there's any pending friend request between two users
  Future<bool> checkIfAnyFriendRequestPending(
    String userId1,
    String userId2,
  ) async {
    try {
      return await _friendsService.checkIfAnyFriendRequestPending(
        userId1,
        userId2,
      );
    } catch (e) {
      print('Error checking friend request status: $e');
      return false;
    }
  }

  /// Comprehensive check of friendship and request status
  Future<Map<String, dynamic>> checkFriendshipAndRequestStatus(
    String otherUserId,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return {
        'isAlreadyFriends': false,
        'hasExistingRequest': false,
        'error': 'User not authenticated',
      };
    }

    try {
      // Check if already friends
      final areFriends = await checkIfFriends(currentUserId, otherUserId);

      // Check if there's any pending request
      final hasRequest = await checkIfAnyFriendRequestPending(
        currentUserId,
        otherUserId,
      );

      return {
        'isAlreadyFriends': areFriends,
        'hasExistingRequest': hasRequest,
        'error': null,
      };
    } catch (e) {
      return {
        'isAlreadyFriends': false,
        'hasExistingRequest': false,
        'error': 'Error checking status: $e',
      };
    }
  }

  /// Gets the current user ID from Firebase Auth
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
