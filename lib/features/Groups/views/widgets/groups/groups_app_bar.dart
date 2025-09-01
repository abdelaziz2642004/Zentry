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
      title: const Text('Study Groups'),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: onCreateGroup),
      ],
      bottom: TabBar(
        controller: tabController,
        labelColor: mainColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: mainColor,
        tabs: const [Tab(text: 'Discover'), Tab(text: 'My Groups')],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48); // AppBar + TabBar height
}
