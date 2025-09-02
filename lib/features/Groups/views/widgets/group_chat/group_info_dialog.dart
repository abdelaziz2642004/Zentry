import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

class GroupInfoDialog extends StatelessWidget {
  final StudyGroup group;

  const GroupInfoDialog({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF05161A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF2CACAD).withOpacity(0.3),
          width: 1,
        ),
      ),
      title: Text(
        group.name,
        style: const TextStyle(
          color: Color(0xFFD9F5F0),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF05161A).withOpacity(0.9),
              const Color(0xFF072E33).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created by: ${group.creatorName}',
              style: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.9)),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${group.category}',
              style: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.9)),
            ),
            const SizedBox(height: 8),
            Text(
              'Members: ${group.memberCount}/${group.maxMembers}',
              style: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.9)),
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${group.isPublic ? "Public" : "Private"}',
              style: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2CACAD),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              group.description,
              style: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.8)),
            ),
            if (group.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Tags:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2CACAD),
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children:
                    group.tags
                        .map(
                          (tag) => Chip(
                            label: Text(
                              '#$tag',
                              style: const TextStyle(
                                color: Color(0xFF05161A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: const Color(
                              0xFF2CACAD,
                            ).withOpacity(0.8),
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.7)),
          ),
        ),
      ],
    );
  }
}
