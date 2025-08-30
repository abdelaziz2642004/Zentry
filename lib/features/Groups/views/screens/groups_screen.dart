import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/discovery_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/my_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/group_card.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/create_group_dialog.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/join_private_group_dialog.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/screens/group_chat_screen.dart';

import 'package:zentry_pomodoro_app/core/colors.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GroupsCubit _groupsCubit;
  late DiscoveryGroupsCubit _discoveryCubit;
  late MyGroupsCubit _myGroupsCubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _groupsCubit = BlocProvider.of<GroupsCubit>(context);
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
      appBar: AppBar(
        title: const Text('Study Groups'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateGroupDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: mainColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: mainColor,
          tabs: const [Tab(text: 'Discover'), Tab(text: 'My Groups')],
        ),
      ),
      body: BlocListener<GroupsCubit, GroupsState>(
        listener: (context, state) {
          print(state);
          if (state is GroupsErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is GroupCreatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload both tabs after creating a group
            _discoveryCubit.loadPublicGroups();
            _myGroupsCubit.loadUserJoinedGroups();
          }
        },
        child: BlocListener<MyGroupsCubit, GroupsState>(
          listener: (context, state) {
            if (state is GroupsErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is GroupJoinedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Joined group successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is GroupLeftState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Left group successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search groups...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      _discoveryCubit.searchGroups(value);
                    } else {
                      _discoveryCubit.loadPublicGroups();
                    }
                  },
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Discover Tab
                    _buildDiscoverTab(),
                    // My Groups Tab
                    _buildMyGroupsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return BlocBuilder<DiscoveryGroupsCubit, GroupsState>(
      builder: (context, state) {
        // Handle loading state
        if (state is PublicGroupsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle loaded state
        if (state is PublicGroupsLoadedState) {
          final groups = state.groups;
          if (groups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No groups found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or create a new group!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _discoveryCubit.loadPublicGroups();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return GroupCardWithMembership(
                  group: group,
                  onJoin: () {
                    if (group.isPrivate) {
                      _showJoinPrivateGroupDialog(group);
                    } else {
                      _myGroupsCubit.joinGroup(group.id);
                    }
                  },
                  onChat:
                      (isMember) =>
                          isMember ? _navigateToGroupChat(group) : null,
                );
              },
            ),
          );
        }

        // Handle error state
        if (state is GroupsErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _discoveryCubit.loadPublicGroups();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Default loading state
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMyGroupsTab() {
    return BlocBuilder<MyGroupsCubit, GroupsState>(
      builder: (context, state) {
        // Handle loading state
        if (state is UserGroupsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle loaded state
        if (state is UserGroupsLoadedState) {
          if (state.groups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No groups joined yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join some groups to start studying together!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _myGroupsCubit.loadUserJoinedGroups();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final group = state.groups[index];
                return GroupCardWithMembership(
                  group: group,
                  onLeave: () {
                    _showLeaveGroupDialog(group);
                  },
                  onChat:
                      (isMember) =>
                          isMember ? _navigateToGroupChat(group) : null,
                );
              },
            ),
          );
        }

        // Handle error state
        if (state is GroupsErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _myGroupsCubit.loadUserJoinedGroups();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Default loading state
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );
  }

  void _showJoinPrivateGroupDialog(dynamic group) {
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

  void _showLeaveGroupDialog(dynamic group) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Leave Group'),
            content: Text('Are you sure you want to leave "${group.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _myGroupsCubit.leaveGroup(group.id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Leave'),
              ),
            ],
          ),
    );
  }

  void _navigateToGroupChat(dynamic group) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupChatScreen(group: group)),
    );
  }
}

// Widget that uses StreamBuilder to check membership status in real-time
class GroupCardWithMembership extends StatelessWidget {
  final dynamic group;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final Function(bool)? onChat;

  const GroupCardWithMembership({
    super.key,
    required this.group,
    this.onJoin,
    this.onLeave,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return GroupCard(
        group: group,
        isUserMember: false,
        onJoin: onJoin,
        onChat: onChat != null ? () => onChat!(false) : null,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('joinedGroups')
              .doc(group.id)
              .snapshots(),
      builder: (context, snapshot) {
        final isMember = snapshot.hasData && snapshot.data!.exists;

        return GroupCard(
          group: group,
          isUserMember: isMember,
          onJoin: onJoin,
          onLeave: onLeave,
          onChat: onChat != null ? () => onChat!(isMember) : null,
        );
      },
    );
  }
}
