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
      title: const Text(
        'Friends',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Color(0xFFD9F5F0),
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF02364A).withOpacity(0.95),
              const Color(0xFF024D60).withOpacity(0.9),
              const Color(0xFF0C7075).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF02364A).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFD9F5F0)),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2CACAD).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.block_outlined,
              color: Color(0xFFD9F5F0),
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlockedUsersScreen(),
                ),
              );
            },
            tooltip: 'Blocked Users',
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2CACAD).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD9F5F0), size: 20),
            onPressed: onRefresh,
            tooltip: 'Refresh',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 4, right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2CACAD).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.person_add,
              color: Color(0xFFD9F5F0),
              size: 20,
            ),
            onPressed: onAddFriend,
            tooltip: 'Add Friend',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
