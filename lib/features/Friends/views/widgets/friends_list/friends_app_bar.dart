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
      title: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    color: const Color(0xFF2CACAD),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: const Color(0xFFD9F5F0),
                      letterSpacing: 1.2,
                      fontFamily: 'monospace',
                      shadows: [
                        Shadow(
                          color: const Color(0xFF2CACAD).withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        // Blocked Users - Beautiful minimal icon
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BlockedUsersScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.block_rounded,
                  color: const Color(0xFFD9F5F0).withOpacity(0.8),
                  size: 24,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                tooltip: 'Blocked Users',
                splashRadius: 24,
                padding: const EdgeInsets.all(12),
              ),
            );
          },
        ),

        // Refresh - Beautiful minimal icon with subtle animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: IconButton(
                onPressed: onRefresh,
                icon: Transform.rotate(
                  angle: value * 0.5, // Subtle rotation animation
                  child: Icon(
                    Icons.refresh_rounded,
                    color: const Color(0xFF2CACAD).withOpacity(0.9),
                    size: 26,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF2CACAD).withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                tooltip: 'Refresh Friends',
                splashRadius: 26,
                padding: const EdgeInsets.all(12),
              ),
            );
          },
        ),

        // Add Friend - Beautiful prominent icon
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: onAddFriend,
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: const Color(0xFF0F9E9C),
                    size: 28,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF0F9E9C).withOpacity(0.5),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                      Shadow(
                        color: const Color(0xFF2CACAD).withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  tooltip: 'Add New Friend',
                  splashRadius: 28,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
