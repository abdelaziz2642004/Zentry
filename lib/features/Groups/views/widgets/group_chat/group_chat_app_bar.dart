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
          Text(
            group.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFFD9F5F0),
            ),
          ),
          Text(
            '${group.memberCount} members',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: const Color(0xFFD9F5F0).withOpacity(0.7),
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
              Icons.info_outline,
              color: Color(0xFFD9F5F0),
              size: 20,
            ),
            onPressed: onShowGroupInfo,
            tooltip: 'Group Info',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
