import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/user_avatar_utils.dart';
import 'package:zentry_pomodoro_app/features/Friends/utils/user_name_utils.dart';

class UserResultList extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final String? selectedUserId;
  final bool isLoading;
  final Function(String userId) onUserSelected;

  const UserResultList({
    super.key,
    required this.searchResults,
    required this.selectedUserId,
    required this.isLoading,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        final isSelected = selectedUserId == user['id'];

        return ListTile(
          leading: UserAvatarUtils.buildUserAvatar(
            user['id'],
            user['fullName'],
          ),
          title: UserNameUtils.buildUserName(user['id'], user['fullName']),
          subtitle: Text('Friend Code: ${user['friendCode'] ?? ''}'),
          trailing:
              isSelected
                  ? const Icon(Icons.check_circle, color: mainColor)
                  : null,
          onTap: () => onUserSelected(user['id']),
        );
      },
    );
  }
}
