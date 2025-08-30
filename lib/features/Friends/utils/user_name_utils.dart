import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class UserNameUtils {
  /// Builds a user name widget with real-time updates from Firestore
  static Widget buildUserName(String userId, String? fallbackName) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(FirebaseConstants.usersCollection)
              .doc(userId)
              .snapshots(),
      builder: (context, snapshot) {
        String displayName = fallbackName ?? '';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            displayName = data[FirebaseConstants.fullNameField] ?? displayName;
          }
        }
        return Text(displayName);
      },
    );
  }

  /// Gets the current user name from Firestore (synchronous)
  static String getUserName(String userId, String? fallbackName) {
    return fallbackName ?? 'Unknown User';
  }

  /// Formats a user name for display
  static String formatUserName(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return 'Unknown User';
    }
    return fullName.trim();
  }

  /// Gets initials from a full name
  static String getInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return 'U';
    }

    final names = fullName.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.length == 1) {
      return names[0][0].toUpperCase();
    }

    return 'U';
  }
}
