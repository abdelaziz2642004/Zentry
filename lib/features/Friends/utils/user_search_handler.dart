import 'package:zentry_pomodoro_app/features/Friends/data/services/friends_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/friend_code_utils.dart';

class UserSearchHandler {
  final FriendsService _friendsService = FriendsService();

  /// Searches for users by friend code
  Future<Map<String, dynamic>> searchUsersByFriendCode(String query) async {
    if (query.trim().isEmpty) {
      return {
        'success': false,
        'results': [],
        'error': 'Search query cannot be empty',
      };
    }

    try {
      // Use utility for friend code validation
      final validation = FriendCodeUtils.validateAndFormatFriendCode(query);

      if (validation['isValid']) {
        // Search by friend code
        final userData = await _friendsService.searchUserByFriendCode(
          validation['formattedCode'],
        );

        return {
          'success': true,
          'results': userData != null ? [userData] : [],
          'error': null,
        };
      } else {
        return {
          'success': false,
          'results': [],
          'error': validation['errorMessage'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'results': [],
        'error': 'Error searching users: $e',
      };
    }
  }

  /// Validates search query format
  bool isValidSearchQuery(String query) {
    return query.trim().isNotEmpty;
  }

  /// Formats search results for display
  List<Map<String, dynamic>> formatSearchResults(
    List<Map<String, dynamic>> results,
  ) {
    return results
        .map(
          (user) => {
            'id': user['id'],
            'fullName': user['fullName'] ?? 'Unknown User',
            'friendCode': user['friendCode'] ?? '',
            'username': user['username'] ?? '',
            'imageUrl': user['imageUrl'] ?? '',
          },
        )
        .toList();
  }
}
