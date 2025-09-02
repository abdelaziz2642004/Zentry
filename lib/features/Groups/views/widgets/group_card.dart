import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_card/group_header_section.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_card/group_info_section.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_card/group_action_buttons.dart';

class GroupCard extends StatelessWidget {
  final StudyGroup group;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onChat;
  final bool isUserMember;

  const GroupCard({
    super.key,
    required this.group,
    this.onJoin,
    this.onLeave,
    this.onChat,
    this.isUserMember = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF05161A).withOpacity(0.8),
            const Color(0xFF072E33).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2CACAD).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2CACAD).withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GroupHeaderSection(group: group),
            const SizedBox(height: 12),
            GroupInfoSection(group: group),
            const SizedBox(height: 12),
            GroupActionButtons(
              group: group,
              isUserMember: isUserMember,
              onJoin: onJoin,
              onLeave: onLeave,
              onChat: onChat,
            ),
          ],
        ),
      ),
    );
  }
}
