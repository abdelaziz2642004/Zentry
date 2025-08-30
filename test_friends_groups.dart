// Test script for Friends and Groups functionality
// Run this in your Flutter app to test the features

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';

class TestFriendsGroupsScreen extends StatefulWidget {
  const TestFriendsGroupsScreen({super.key});

  @override
  State<TestFriendsGroupsScreen> createState() =>
      _TestFriendsGroupsScreenState();
}

class _TestFriendsGroupsScreenState extends State<TestFriendsGroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Friends & Groups')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Friends & Groups Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Test Friends
            const Text(
              'Friends Tests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Test sending friend request
                context.read<FriendsCubit>().sendFriendRequest(
                  receiverUsername: 'test_user',
                  message: 'Hi! Let\'s study together!',
                );
              },
              child: const Text('Send Friend Request'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Test loading friends list
                context.read<FriendsCubit>().loadFriendsList();
              },
              child: const Text('Load Friends List'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Test loading friend requests
                context.read<FriendsCubit>().loadPendingFriendRequests();
              },
              child: const Text('Load Friend Requests'),
            ),

            const SizedBox(height: 20),

            // Test Groups
            const Text(
              'Groups Tests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Test creating a group
                context.read<GroupsCubit>().createGroup(
                  name: 'Test Study Group',
                  description: 'A test group for studying together',
                  isPublic: true,
                  maxMembers: 10,
                  tags: ['test', 'study'],
                  category: 'General',
                );
              },
              child: const Text('Create Test Group'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Test loading public groups
                context.read<GroupsCubit>().loadPublicGroups();
              },
              child: const Text('Load Public Groups'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Test loading user's groups
                context.read<GroupsCubit>().loadUserJoinedGroups();
              },
              child: const Text('Load My Groups'),
            ),

            const SizedBox(height: 20),

            // Status indicators
            BlocBuilder<FriendsCubit, FriendsState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Friends Status:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('State: ${state.runtimeType}'),
                      if (state is FriendsErrorState)
                        Text('Error: ${state.error}'),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            BlocBuilder<GroupsCubit, GroupsState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Groups Status:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('State: ${state.runtimeType}'),
                      if (state is GroupsErrorState)
                        Text('Error: ${state.error}'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Instructions for testing:
/*
1. Add this screen to your navigation temporarily
2. Make sure you're logged in with a test account
3. Create another test account to test friend requests
4. Test each button and check the status indicators
5. Verify that data is being created in Firebase
6. Test the real Friends and Groups screens

Test Scenarios:
- Send friend request between two accounts
- Accept/reject friend requests
- Create a public group
- Join a group with another account
- Search for groups
- Invite friends to rooms

Expected Results:
- Friend requests should appear in the requests tab
- Groups should appear in the discover tab
- No permission errors in Firebase
- Real-time updates working
*/
