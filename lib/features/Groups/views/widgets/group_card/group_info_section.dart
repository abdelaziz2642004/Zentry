import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

class GroupInfoSection extends StatelessWidget {
  final StudyGroup group;

  const GroupInfoSection({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.description,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${group.memberCount}/${group.maxMembers}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const Spacer(),
            if (group.tags.isNotEmpty) ...[
              ...group.tags
                  .take(2)
                  .map(
                    (tag) => Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(color: Colors.grey[700], fontSize: 10),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ],
    );
  }
}
