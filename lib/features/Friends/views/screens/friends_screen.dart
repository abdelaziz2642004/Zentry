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
      appBar: FriendsAppBar(
        onRefresh: _refreshFriendsList,
        onAddFriend: _showAddFriendDialog,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: mainColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: mainColor,
              tabs: const [Tab(text: 'Friends'), Tab(text: 'Requests')],
            ),
          ),
          Expanded(
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
              child: TabBarView(
                controller: _tabController,
                children: const [FriendsTab(), RequestsTab()],
              ),
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

  void _handleFriendsStateChanges(BuildContext context, FriendsState state) {
    if (_disposed) return;

    if (state is FriendsErrorState) {
      print('Error: ${state.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error), backgroundColor: Colors.red),
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
        SnackBar(content: Text(state.error), backgroundColor: Colors.red),
      );
    } else if (state is FriendRequestSentState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state is FriendRequestAcceptedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request accepted!'),
          backgroundColor: Colors.green,
        ),
      );
      if (!_disposed) {
        _friendsListCubit.loadFriendsList();
      }
    } else if (state is FriendRequestRejectedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request rejected'),
          backgroundColor: Colors.orange,
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
        SnackBar(content: Text(state.error), backgroundColor: Colors.red),
      );
    } else if (state is FriendRemovedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend removed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
