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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
