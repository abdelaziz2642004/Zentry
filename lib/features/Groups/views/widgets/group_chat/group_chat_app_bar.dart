import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

class GroupChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final StudyGroup group;
  final VoidCallback onShowGroupInfo;

  const GroupChatAppBar({
    super.key,
    required this.group,
    required this.onShowGroupInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.name),
          Text(
            '${group.memberCount} members',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: onShowGroupInfo,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
