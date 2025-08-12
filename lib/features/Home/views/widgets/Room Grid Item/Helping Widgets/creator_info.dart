import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';

class CreatorInfo extends StatelessWidget {
  const CreatorInfo({super.key, required this.creatorId});

  final String creatorId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection(FirebaseConstants.usersCollection)
              .doc(creatorId)
              .snapshots(),
      builder: (context, snapshot) {
        String creatorName = "Loading...";
        String? imageUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data();
          if (data != null) {
            creatorName = data[FirebaseConstants.fullNameField] ?? "Unknown";
            imageUrl = data[FirebaseConstants.imageUrlField];
            if (imageUrl != null && imageUrl.isEmpty) imageUrl = null;
          }
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: grey,
              radius: 12,
              child:
                  imageUrl != null
                      ? CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: CachedNetworkImageProvider(imageUrl),
                      )
                      : const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                "by $creatorName",
                style: const TextStyle(fontSize: 10, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
