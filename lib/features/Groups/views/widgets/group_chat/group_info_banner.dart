import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

class GroupInfoBanner extends StatelessWidget {
  final StudyGroup group;

  const GroupInfoBanner({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2CACAD).withOpacity(0.1),
            const Color(0xFF0F9E9C).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2CACAD).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2CACAD).withOpacity(0.2),
            backgroundImage:
                group.imageUrl.isNotEmpty ? NetworkImage(group.imageUrl) : null,
            child:
                group.imageUrl.isEmpty
                    ? Text(
                      group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2CACAD),
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFD9F5F0),
                  ),
                ),
                Text(
                  group.description,
                  style: TextStyle(
                    color: const Color(0xFFD9F5F0).withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
