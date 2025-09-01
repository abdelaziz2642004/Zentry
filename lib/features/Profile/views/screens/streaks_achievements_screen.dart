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
        children: const [
          // Streaks Section
          Text(
            'Current Streaks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: Fonts.dopisBold,
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.local_fire_department,
                color: Colors.orange,
              ),
              title: Text('Daily Streak'),
              subtitle: Text(
                '5 days',
              ), // You'll need to connect this to actual data
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.timer, color: mainColor),
              title: Text('Focus Time'),
              subtitle: Text('2 hours today'), // Connect to actual data
            ),
          ),

          SizedBox(height: 24),

          // Achievements Section
          Text(
            'Achievements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: Fonts.dopisBold,
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.amber),
              title: Text('Early Bird'),
              subtitle: Text('Complete 5 morning sessions'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.grey),
              title: Text('Focus Master'),
              subtitle: Text('Complete 10 sessions without breaks'),
              trailing: Icon(Icons.lock),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.grey),
              title: Text('Consistency King'),
              subtitle: Text('Maintain a 7-day streak'),
              trailing: Icon(Icons.lock),
            ),
          ),
        ],
      ),
    );
  }
}