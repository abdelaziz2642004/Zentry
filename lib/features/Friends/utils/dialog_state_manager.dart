import 'package:flutter/material.dart';

class DialogStateManager {
  /// Manages user selection state
  static Map<String, dynamic> handleUserSelection({
    required String userId,
    required bool hasExistingRequest,
    required bool isAlreadyFriends,
  }) {
    return {
      'selectedUserId': userId,
      'hasExistingRequest': false, // Reset state
      'isAlreadyFriends': false, // Reset state
    };
  }

  /// Validates if dialog can be closed
  static bool canCloseDialog({
    required bool isSearching,
    required bool isCheckingRequest,
  }) {
    return !isSearching && !isCheckingRequest;
  }

  /// Gets appropriate dialog title based on state
  static String getDialogTitle({
    required bool isSearching,
    required bool hasResults,
  }) {
    if (isSearching) {
      return 'Searching...';
    } else if (hasResults) {
      return 'Select User';
    } else {
      return 'Add Friend';
    }
  }

  /// Determines if message input should be shown
  static bool shouldShowMessageInput(String? selectedUserId) {
    return selectedUserId != null;
  }

  /// Validates message input
  static String? validateMessage(String message) {
    if (message.trim().length > 500) {
      return 'Message is too long (max 500 characters)';
    }
    return null;
  }

  /// Formats message for sending
  static String formatMessage(String message) {
    return message.trim();
  }
}
