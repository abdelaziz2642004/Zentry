// Quick Test Guide for Adding Friends
// Add this temporarily to your navigation to test

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_states.dart';

class TestAddFriendGuide extends StatelessWidget {
  const TestAddFriendGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Add Friend')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How to Add Friends',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Step 1
            _buildStep(
              'Step 1: Open Friends Tab',
              'Tap the 👥 (People) icon in the bottom navigation',
              Icons.people,
            ),

            const SizedBox(height: 16),

            // Step 2
            _buildStep(
              'Step 2: Tap Add Friend',
              'Press the ➕ button in the top right corner',
              Icons.person_add,
            ),

            const SizedBox(height: 16),

            // Step 3
            _buildStep(
              'Step 3: Search Username',
              'Enter the username of the person you want to add',
              Icons.search,
            ),

            const SizedBox(height: 16),

            // Step 4
            _buildStep(
              'Step 4: Send Request',
              'Add a message and tap "Send Request"',
              Icons.send,
            ),

            const SizedBox(height: 20),

            // Test Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🧪 Quick Test:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Create two test accounts\n'
                    '2. Use one account to send friend request\n'
                    '3. Switch to other account to accept\n'
                    '4. Verify you appear in each other\'s friends list',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status
            BlocBuilder<FriendsCubit, FriendsState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Status:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('State: ${state.runtimeType}'),
                      if (state is FriendsErrorState)
                        Text(
                          'Error: ${state.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (state is FriendRequestSentState)
                        const Text(
                          '✅ Friend request sent successfully!',
                          style: TextStyle(color: Colors.green),
                        ),
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

  Widget _buildStep(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
To test this guide:

1. Temporarily add this screen to your navigation
2. Follow the steps to understand the flow
3. Test with real accounts
4. Remove this test screen when done

Example usage in tabs.dart:
case 3:
  return const TestAddFriendGuide();
*/
