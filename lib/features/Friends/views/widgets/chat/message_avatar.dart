import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/chat_message.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/message_bubble_utils.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class MessageAvatar extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final Function(String)? onViewProfile;
  final double radius;

  const MessageAvatar({
    super.key,
    required this.message,
    required this.isMe,
    this.onViewProfile,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onViewProfile?.call(message.senderId),
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(FirebaseConstants.usersCollection)
                .doc(message.senderId)
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
              radius: radius,
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image loading error silently
              },
            );
          } else {
            return CircleAvatar(
              radius: radius,
              backgroundColor: MessageBubbleUtils.getAvatarBackgroundColor(
                isMe,
              ),
              child: Text(
                MessageBubbleUtils.getUserInitials(message.senderName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
