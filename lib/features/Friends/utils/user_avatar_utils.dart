import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class UserAvatarUtils {
  /// Builds a user avatar widget with real-time updates from Firestore
  static Widget buildUserAvatar(String userId, String? fallbackName) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(FirebaseConstants.usersCollection)
              .doc(userId)
              .snapshots(),
      builder: (context, snapshot) {
        String? imageUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            imageUrl = data[FirebaseConstants.imageUrlField];
            if (imageUrl != null && imageUrl.isEmpty) imageUrl = null;
          }
        }

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle image loading error silently
            },
          );
        } else {
          return CircleAvatar(
            backgroundColor: Colors.grey[400],
            child: Text(
              (fallbackName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      },
    );
  }

  /// Builds a static user avatar widget (no real-time updates)
  static Widget buildStaticUserAvatar(String? imageUrl, String? fallbackName) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle image loading error silently
        },
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.grey[400],
        child: Text(
          (fallbackName ?? 'U')[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
