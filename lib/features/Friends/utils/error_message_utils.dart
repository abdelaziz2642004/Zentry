class ErrorMessageUtils {
  /// Formats friend request error messages for user display
  static String formatFriendRequestError(String error) {
    if (error.contains('Friend request already sent')) {
      return 'Request already sent! Please wait for them to accept or decline so you can send again.';
    } else if (error.contains('Already friends')) {
      return 'You are already friends with this person!';
    } else if (error.contains('Cannot send friend request to yourself')) {
      return 'You cannot send a friend request to yourself!';
    } else if (error.contains('user is blocked')) {
      return 'Cannot send friend request - user is blocked or has blocked you.';
    } else if (error.contains('User not found')) {
      return 'User not found.';
    } else {
      return 'Error sending friend request: $error';
    }
  }

  /// Formats general error messages
  static String formatGeneralError(String error, String context) {
    if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else if (error.contains('permission') || error.contains('unauthorized')) {
      return 'Permission denied. Please check your account settings.';
    } else if (error.contains('not found')) {
      return 'The requested item was not found.';
    } else {
      return 'Error in $context: $error';
    }
  }

  /// Gets appropriate error icon based on error type
  static String getErrorIcon(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return 'wifi_off';
    } else if (error.contains('permission') || error.contains('unauthorized')) {
      return 'lock';
    } else if (error.contains('not found')) {
      return 'search_off';
    } else {
      return 'error_outline';
    }
  }

  /// Determines if error is retryable
  static bool isRetryableError(String error) {
    return error.contains('network') ||
        error.contains('connection') ||
        error.contains('timeout') ||
        error.contains('server');
  }
}
