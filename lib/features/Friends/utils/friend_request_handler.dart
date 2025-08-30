import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';

class FriendRequestHandler {
  final FriendsService _friendsService = FriendsService();

  /// Accepts an existing friend request
  Future<Map<String, dynamic>> acceptExistingRequest(String otherUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return {
        'success': false,
        'message': 'User not authenticated',
        'error': 'Authentication required',
      };
    }

    try {
      // Find the existing request ID
      final requestId = await _friendsService.getFriendRequestId(
        otherUserId,
        currentUserId,
      );

      if (requestId != null) {
        // Accept the existing request
        await _friendsService.acceptFriendRequest(requestId);

        return {
          'success': true,
          'message': 'Friend request accepted!',
          'error': null,
        };
      } else {
        return {
          'success': false,
          'message': 'Friend request not found',
          'error': 'Request not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error accepting friend request',
        'error': 'Error: $e',
      };
    }
  }

  /// Rejects an existing friend request
  Future<Map<String, dynamic>> rejectExistingRequest(String otherUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return {
        'success': false,
        'message': 'User not authenticated',
        'error': 'Authentication required',
      };
    }

    try {
      // Find the existing request ID
      final requestId = await _friendsService.getFriendRequestId(
        otherUserId,
        currentUserId,
      );

      if (requestId != null) {
        // Reject the existing request
        await _friendsService.rejectFriendRequest(requestId);

        return {
          'success': true,
          'message': 'Friend request rejected!',
          'error': null,
        };
      } else {
        return {
          'success': false,
          'message': 'Friend request not found',
          'error': 'Request not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error rejecting friend request',
        'error': 'Error: $e',
      };
    }
  }

  /// Sends a friend request to another user
  Future<Map<String, dynamic>> sendFriendRequest(
    String receiverId,
    String message,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return {
        'success': false,
        'message': 'User not authenticated',
        'error': 'Authentication required',
      };
    }

    try {
      await _friendsService.sendFriendRequestById(
        receiverId: receiverId,
        message: message,
      );

      return {
        'success': true,
        'message': 'Friend request sent!',
        'error': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending friend request',
        'error': 'Error: $e',
      };
    }
  }

  /// Gets the current user ID from Firebase Auth
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
