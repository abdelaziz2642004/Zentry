import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/screens/view_profile_screen.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String otherUserId;
  final String otherUserName;
  final VoidCallback onMorePressed;

  const ChatAppBar({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ViewProfileScreen(userId: otherUserId),
                ),
              );
            },
            child: StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection(FirebaseConstants.usersCollection)
                      .doc(otherUserId)
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

                return CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      imageUrl != null && imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                  child:
                      imageUrl == null || imageUrl.isEmpty
                          ? Text(
                            otherUserName.isNotEmpty
                                ? otherUserName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.more_vert), onPressed: onMorePressed),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
