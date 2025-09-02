import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class GroupsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCreateGroup;
  final TabController tabController;

  const GroupsAppBar({
    super.key,
    required this.onCreateGroup,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Study Groups',
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
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2CACAD).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFD9F5F0), size: 20),
            onPressed: onCreateGroup,
            tooltip: 'Create Group',
          ),
        ),
      ],
      bottom: TabBar(
        controller: tabController,
        labelColor: const Color(0xFF2CACAD),
        unselectedLabelColor: const Color(0xFFD9F5F0).withOpacity(0.6),
        indicatorColor: const Color(0xFF2CACAD),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        tabs: const [Tab(text: 'Discover'), Tab(text: 'My Groups')],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48); // AppBar + TabBar height
}
