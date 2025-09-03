import 'dart:math' as math;
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
      body: Stack(
        children: [
          // Advanced animated background with particles
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 20),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.3 + (0.4 * math.sin(value * 2 * math.pi)),
                      -0.2 + (0.3 * math.cos(value * 2 * math.pi)),
                    ),
                    radius: 1.2 + (0.3 * math.sin(value * 3 * math.pi)),
                    colors: [
                      const Color(0xFF2CACAD).withOpacity(0.08),
                      const Color(0xFF0F9E9C).withOpacity(0.04),
                      const Color(0xFF05161A).withOpacity(0.9),
                      const Color(0xFF05161A),
                    ],
                    stops: const [0.0, 0.2, 0.6, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Floating particles
                    ...List.generate(8, (index) {
                      final offset = (value + index * 0.125) % 1.0;
                      return Positioned(
                        left:
                            50 +
                            (index * 45) +
                            (30 * math.sin(offset * 2 * math.pi)),
                        top:
                            100 +
                            (index * 80) +
                            (40 * math.cos(offset * 2 * math.pi)),
                        child: Opacity(
                          opacity: 0.1 + (0.1 * math.sin(offset * 4 * math.pi)),
                          child: Container(
                            width: 4 + (2 * math.sin(offset * 6 * math.pi)),
                            height: 4 + (2 * math.sin(offset * 6 * math.pi)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2CACAD),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2CACAD,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // Main content
          MultiBlocListener(
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
                // Enhanced search with animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: GroupsSearchBar(
                          controller: _searchController,
                          onSearchChanged: _handleSearchChanged,
                        ),
                      ),
                    );
                  },
                ),

                // Content with staggered animation
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                DiscoverGroupsTab(
                                  onJoinGroup:
                                      (group) => _handleJoinGroup(group),
                                  onJoinPrivateGroup:
                                      (group) => _handleJoinPrivateGroup(group),
                                  onNavigateToChat:
                                      (group) => _navigateToGroupChat(group),
                                ),
                                MyGroupsTab(
                                  onLeaveGroup:
                                      (group) => _handleLeaveGroup(group),
                                  onNavigateToChat:
                                      (group) => _navigateToGroupChat(group),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Ultra-Modern Floating Action System
          Positioned(
            bottom: 20,
            right: 20,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Advanced Quick Actions with morphing
                      TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 3),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, pulseValue, child) {
                          return Transform.scale(
                            scale:
                                1.0 +
                                (0.05 * math.sin(pulseValue * 4 * math.pi)),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF2CACAD).withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2CACAD).withOpacity(
                                      0.3 +
                                          (0.2 *
                                              math.sin(
                                                pulseValue * 2 * math.pi,
                                              )),
                                    ),
                                    blurRadius:
                                        20 +
                                        (10 *
                                            math.sin(pulseValue * 2 * math.pi)),
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: FloatingActionButton(
                                heroTag: "join_private",
                                mini: true,
                                backgroundColor: const Color(
                                  0xFF072E33,
                                ).withOpacity(0.9),
                                foregroundColor: const Color(0xFF2CACAD),
                                elevation: 12,
                                onPressed: _showJoinByCodeDialog,
                                child: Transform.rotate(
                                  angle: pulseValue * 0.2,
                                  child: const Icon(
                                    Icons.vpn_key_rounded,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Main Create Group FAB with advanced effects
                      TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 4),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, animValue, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2CACAD),
                                  const Color(0xFF0F9E9C),
                                  const Color(0xFF2CACAD),
                                ],
                                stops: [
                                  0.0,
                                  0.5 +
                                      (0.3 * math.sin(animValue * 2 * math.pi)),
                                  1.0,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2CACAD,
                                  ).withOpacity(0.4),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF0F9E9C).withOpacity(
                                    0.3 +
                                        (0.2 *
                                            math.sin(animValue * 3 * math.pi)),
                                  ),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FloatingActionButton.extended(
                              heroTag: "create_group",
                              onPressed: _showCreateGroupDialog,
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFF05161A),
                              elevation: 0,
                              splashColor: const Color(
                                0xFF05161A,
                              ).withOpacity(0.2),
                              icon: Transform.scale(
                                scale:
                                    1.0 +
                                    (0.1 * math.sin(animValue * 6 * math.pi)),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 26,
                                ),
                              ),
                              label: Text(
                                'Create Group',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: const Color(
                                        0xFF05161A,
                                      ).withOpacity(0.3),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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

  void _showJoinByCodeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF05161A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: const Color(0xFF2CACAD).withOpacity(0.3),
                width: 1,
              ),
            ),
            title: Text(
              'Join Private Group',
              style: TextStyle(
                color: const Color(0xFFD9F5F0),
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Enter the group code to join a private study group',
              style: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: const Color(0xFFD9F5F0).withOpacity(0.7),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement join by code functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CACAD),
                  foregroundColor: const Color(0xFF05161A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Join'),
              ),
            ],
          ),
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
