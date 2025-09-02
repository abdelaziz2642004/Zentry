import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

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
              showDialog(
                context: context,
                builder: (context) => ProfilePopupDialog(userId: otherUserId),
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
                  backgroundColor: const Color(0xFF2CACAD).withOpacity(0.2),
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
                              color: Color(0xFF2CACAD),
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
                    color: Color(0xFFD9F5F0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF02364A).withOpacity(0.95),
              const Color(0xFF024D60).withOpacity(0.9),
              const Color(0xFF0C7075).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF02364A).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFD9F5F0)),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2CACAD).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFFD9F5F0),
              size: 20,
            ),
            onPressed: onMorePressed,
            tooltip: 'More Options',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
