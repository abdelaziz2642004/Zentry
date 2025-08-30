import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

class GroupHeaderSection extends StatelessWidget {
  final StudyGroup group;

  const GroupHeaderSection({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage:
              group.imageUrl.isNotEmpty ? NetworkImage(group.imageUrl) : null,
          child:
              group.imageUrl.isEmpty
                  ? Text(
                    group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
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
        _buildCategoryChip(),
      ],
    );
  }

  Widget _buildCategoryChip() {
    Color chipColor;
    Color textColor;

    switch (group.category) {
      case 'Math':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        break;
      case 'Science':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        break;
      case 'Literature':
        chipColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        group.category,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
