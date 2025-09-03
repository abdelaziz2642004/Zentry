import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/online_status_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_list_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friend_requests_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friends_list/friends_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friends_list/friends_tab.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friend_requests/requests_tab.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/add_friend/add_friend_dialog.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FriendsListCubit _friendsListCubit;
  late FriendRequestsCubit _friendRequestsCubit;
  final OnlineStatusService _onlineStatusService = OnlineStatusService();
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _friendsListCubit = BlocProvider.of<FriendsListCubit>(context);
    _friendRequestsCubit = BlocProvider.of<FriendRequestsCubit>(context);

    _ensureUserOnline();
    _setupTabListener();
  }

  @override
  void dispose() {
    _disposed = true;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05161A),
      appBar: FriendsAppBar(
        onRefresh: _refreshFriendsList,
        onAddFriend: _showAddFriendDialog,
      ),
      body: Stack(
        children: [
          // Background gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  const Color(0xFF2CACAD).withOpacity(0.05),
                  const Color(0xFF05161A).withOpacity(0.8),
                  const Color(0xFF05161A),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Enhanced tab bar with animations
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF05161A).withOpacity(0.95),
                              const Color(0xFF072E33).withOpacity(0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2CACAD).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2CACAD).withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFFD9F5F0),
                            unselectedLabelColor: const Color(
                              0xFFD9F5F0,
                            ).withOpacity(0.6),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2CACAD).withOpacity(0.8),
                                  const Color(0xFF0F9E9C).withOpacity(0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2CACAD,
                                  ).withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            tabs: [
                              Tab(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 20,
                                        color:
                                            _tabController.index == 0
                                                ? const Color(0xFFD9F5F0)
                                                : const Color(
                                                  0xFFD9F5F0,
                                                ).withOpacity(0.6),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Friends'),
                                    ],
                                  ),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_add_outlined,
                                        size: 20,
                                        color:
                                            _tabController.index == 1
                                                ? const Color(0xFFD9F5F0)
                                                : const Color(
                                                  0xFFD9F5F0,
                                                ).withOpacity(0.6),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Requests'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        child: MultiBlocListener(
                          listeners: [
                            BlocListener<FriendsCubit, FriendsState>(
                              listener: _handleFriendsStateChanges,
                            ),
                            BlocListener<FriendRequestsCubit, FriendsState>(
                              listener: _handleFriendRequestsStateChanges,
                            ),
                            BlocListener<FriendsListCubit, FriendsState>(
                              listener: _handleFriendsListStateChanges,
                            ),
                          ],
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: TabBarView(
                              controller: _tabController,
                              children: const [FriendsTab(), RequestsTab()],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating Quick Actions
          Positioned(
            bottom: 20,
            right: 20,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: FloatingActionButton.extended(
                    onPressed: _showQuickActionsDialog,
                    backgroundColor: const Color(0xFF2CACAD),
                    foregroundColor: const Color(0xFF05161A),
                    elevation: 8,
                    icon: const Icon(Icons.add_circle_outline, size: 24),
                    label: const Text(
                      'Quick Add',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ensureUserOnline() async {
    if (_disposed) return;

    try {
      await _onlineStatusService.setUserOnline();
      print('User online status ensured in FriendsScreen');
      if (!_disposed) {
        _friendsListCubit.loadFriendsList();
      }
    } catch (e) {
      print('Error ensuring user online status: $e');
    }
  }

  void _setupTabListener() {
    _tabController.addListener(() {
      if (_disposed) return;

      if (_tabController.index == 0) {
        _friendsListCubit.loadFriendsList();
      } else if (_tabController.index == 1) {
        _friendRequestsCubit.loadPendingFriendRequests();
      }
    });
  }

  void _refreshFriendsList() {
    if (!_disposed) {
      _ensureUserOnline();
    }
  }

  void _showAddFriendDialog() {
    if (!_disposed) {
      showDialog(
        context: context,
        builder: (context) => const AddFriendDialog(),
      );
    }
  }

  void _showQuickActionsDialog() {
    if (!_disposed) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder:
            (context) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF05161A).withOpacity(0.95),
                    const Color(0xFF072E33).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                border: Border.all(
                  color: const Color(0xFF2CACAD).withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2CACAD).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD9F5F0),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.person_add_outlined,
                        label: 'Add Friend',
                        onTap: () {
                          Navigator.pop(context);
                          _showAddFriendDialog();
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan Code',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement QR code scanning
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.share,
                        label: 'Share Code',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement friend code sharing
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      );
    }
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2CACAD).withOpacity(0.2),
              const Color(0xFF0F9E9C).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2CACAD).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF2CACAD)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD9F5F0),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleFriendsStateChanges(BuildContext context, FriendsState state) {
    if (_disposed) return;

    if (state is FriendsErrorState) {
      print('Error: ${state.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error,
            style: const TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF072E33),
        ),
      );
    }
  }

  void _handleFriendRequestsStateChanges(
    BuildContext context,
    FriendsState state,
  ) {
    if (_disposed) return;

    if (state is FriendsErrorState) {
      print('Error: ${state.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error,
            style: const TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF072E33),
        ),
      );
    } else if (state is FriendRequestSentState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Friend request sent!',
            style: TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF2CACAD),
        ),
      );
    } else if (state is FriendRequestAcceptedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Friend request accepted!',
            style: TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF2CACAD),
        ),
      );
      if (!_disposed) {
        _friendsListCubit.loadFriendsList();
      }
    } else if (state is FriendRequestRejectedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Friend request rejected',
            style: TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF0F9E9C),
        ),
      );
    }
  }

  void _handleFriendsListStateChanges(
    BuildContext context,
    FriendsState state,
  ) {
    if (_disposed) return;

    if (state is FriendsErrorState) {
      print('Error: ${state.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error,
            style: const TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF072E33),
        ),
      );
    } else if (state is FriendRemovedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Friend removed',
            style: TextStyle(color: Color(0xFFD9F5F0)),
          ),
          backgroundColor: const Color(0xFF0F9E9C),
        ),
      );
    }
  }
}
