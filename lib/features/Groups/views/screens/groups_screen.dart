import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/discovery_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/my_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/groups/groups_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/groups/groups_search_bar.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/groups/discover_groups_tab.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/groups/my_groups_tab.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/groups/leave_group_dialog.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/create_group_dialog.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/join_private_group_dialog.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/screens/group_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DiscoveryGroupsCubit _discoveryCubit;
  late MyGroupsCubit _myGroupsCubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _discoveryCubit = BlocProvider.of<DiscoveryGroupsCubit>(context);
    _myGroupsCubit = BlocProvider.of<MyGroupsCubit>(context);

    // Load initial data
    _discoveryCubit.loadPublicGroups();
    _myGroupsCubit.loadUserJoinedGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05161A),
      appBar: GroupsAppBar(
        onCreateGroup: _showCreateGroupDialog,
        tabController: _tabController,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<GroupsCubit, GroupsState>(
            listener: _handleGroupsStateChanges,
          ),
          BlocListener<MyGroupsCubit, GroupsState>(
            listener: _handleMyGroupsStateChanges,
          ),
        ],
        child: Column(
          children: [
            GroupsSearchBar(
              controller: _searchController,
              onSearchChanged: _handleSearchChanged,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  DiscoverGroupsTab(
                    onJoinGroup: (group) => _handleJoinGroup(group),
                    onJoinPrivateGroup:
                        (group) => _handleJoinPrivateGroup(group),
                    onNavigateToChat: (group) => _navigateToGroupChat(group),
                  ),
                  MyGroupsTab(
                    onLeaveGroup: (group) => _handleLeaveGroup(group),
                    onNavigateToChat: (group) => _navigateToGroupChat(group),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearchChanged(String value) {
    if (value.trim().isNotEmpty) {
      _discoveryCubit.searchGroups(value);
    } else {
      _discoveryCubit.loadPublicGroups();
    }
  }

  void _handleGroupsStateChanges(BuildContext context, GroupsState state) {
    if (state is GroupsErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error,
            style: const TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF072E33),
        ),
      );
    } else if (state is GroupCreatedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Group created successfully!',
            style: TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF2CACAD),
        ),
      );
      // Reload both tabs after creating a group
      _discoveryCubit.loadPublicGroups();
      _myGroupsCubit.loadUserJoinedGroups();
    }
  }

  void _handleMyGroupsStateChanges(BuildContext context, GroupsState state) {
    if (state is GroupsErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error,
            style: const TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF072E33),
        ),
      );
    } else if (state is GroupJoinedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Joined group successfully!',
            style: TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF2CACAD),
        ),
      );
    } else if (state is GroupLeftState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Left group successfully',
            style: TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF0F9E9C),
        ),
      );
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );
  }

  void _handleJoinGroup(dynamic group) {
    _myGroupsCubit.joinGroup(group.id);
  }

  void _handleJoinPrivateGroup(dynamic group) {
    showDialog(
      context: context,
      builder:
          (context) => JoinPrivateGroupDialog(
            group: group,
            onJoin: (password) {
              _myGroupsCubit.joinGroup(group.id, password: password);
            },
          ),
    );
  }

  void _handleLeaveGroup(dynamic group) {
    showDialog(
      context: context,
      builder:
          (context) => LeaveGroupDialog(
            groupName: group.name,
            onLeave: () => _myGroupsCubit.leaveGroup(group.id),
          ),
    );
  }

  void _navigateToGroupChat(dynamic group) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupChatScreen(group: group)),
    );
  }
}
