import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/fonts.dart';

class StreaksAndAchievementsScreen extends StatelessWidget {
  const StreaksAndAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Streaks & Achievements',
          style: TextStyle(fontFamily: Fonts.dopisBold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Streaks Section
          const Text(
            'Current Streaks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: Fonts.dopisBold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
              ),
              title: const Text('Daily Streak'),
              subtitle: const Text(
                '5 days',
              ), // You'll need to connect this to actual data
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer, color: mainColor),
              title: const Text('Focus Time'),
              subtitle: const Text('2 hours today'), // Connect to actual data
            ),
          ),

          const SizedBox(height: 24),

          // Achievements Section
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: Fonts.dopisBold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text('Early Bird'),
              subtitle: const Text('Complete 5 morning sessions'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.grey),
              title: const Text('Focus Master'),
              subtitle: const Text('Complete 10 sessions without breaks'),
              trailing: const Icon(Icons.lock),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.grey),
              title: const Text('Consistency King'),
              subtitle: const Text('Maintain a 7-day streak'),
              trailing: const Icon(Icons.lock),
            ),
          ),
        ],
      ),
    );
  }
}