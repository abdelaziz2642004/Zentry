import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

class GroupInfoDialog extends StatelessWidget {
  final StudyGroup group;

  const GroupInfoDialog({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(group.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Created by: ${group.creatorName}'),
          const SizedBox(height: 8),
          Text('Category: ${group.category}'),
          const SizedBox(height: 8),
          Text('Members: ${group.memberCount}/${group.maxMembers}'),
          const SizedBox(height: 8),
          Text('Type: ${group.isPublic ? "Public" : "Private"}'),
          const SizedBox(height: 16),
          const Text(
            'Description:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(group.description),
          if (group.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children:
                  group.tags
                      .map(
                        (tag) => Chip(
                          label: Text('#$tag'),
                          backgroundColor: Colors.grey[200],
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
