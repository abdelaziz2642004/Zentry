import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_card.dart';

class GroupCardWithMembership extends StatelessWidget {
  final dynamic group;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final Function(bool)? onChat;

  const GroupCardWithMembership({
    super.key,
    required this.group,
    this.onJoin,
    this.onLeave,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return GroupCard(
        group: group,
        isUserMember: false,
        onJoin: onJoin,
        onChat: onChat != null ? () => onChat!(false) : null,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('joinedGroups')
              .doc(group.id)
              .snapshots(),
      builder: (context, snapshot) {
        final isMember = snapshot.hasData && snapshot.data!.exists;

        return GroupCard(
          group: group,
          isUserMember: isMember,
          onJoin: onJoin,
          onLeave: onLeave,
          onChat: onChat != null ? () => onChat!(isMember) : null,
        );
      },
    );
  }
}
