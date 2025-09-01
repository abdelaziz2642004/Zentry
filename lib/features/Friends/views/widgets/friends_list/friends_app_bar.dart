import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/screens/blocked_users_screen.dart';

class FriendsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;
  final VoidCallback onAddFriend;

  const FriendsAppBar({
    super.key,
    required this.onRefresh,
    required this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Friends'),
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.block_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BlockedUsersScreen(),
              ),
            );
          },
        ),
        IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh),
        IconButton(icon: const Icon(Icons.person_add), onPressed: onAddFriend),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
