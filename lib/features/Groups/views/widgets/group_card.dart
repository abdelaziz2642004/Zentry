import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

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
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      group.imageUrl.isNotEmpty
                          ? NetworkImage(group.imageUrl)
                          : null,
                  child:
                      group.imageUrl.isEmpty
                          ? Text(
                            group.name.isNotEmpty
                                ? group.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (group.isPrivate) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Private',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'by ${group.creatorName}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        group.category == 'Math'
                            ? Colors.blue[100]
                            : group.category == 'Science'
                            ? Colors.green[100]
                            : group.category == 'Literature'
                            ? Colors.purple[100]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.category,
                    style: TextStyle(
                      color:
                          group.category == 'Math'
                              ? Colors.blue[700]
                              : group.category == 'Science'
                              ? Colors.green[700]
                              : group.category == 'Literature'
                              ? Colors.purple[700]
                              : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isUserMember) ...[
                  // User is a member - show chat and leave options
                  if (onChat != null) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onChat,
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onLeave != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onLeave,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Leave'),
                      ),
                    ),
                  ],
                ] else ...[
                  // User is not a member - show join option
                  if (onJoin != null) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: group.canJoin ? onJoin : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          group.isFull
                              ? 'Full'
                              : group.isPrivate
                              ? 'Join Private'
                              : 'Join',
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
