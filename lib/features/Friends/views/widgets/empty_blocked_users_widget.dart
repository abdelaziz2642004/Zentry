import 'package:flutter/material.dart';

class EmptyBlockedUsersWidget extends StatelessWidget {
  const EmptyBlockedUsersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No blocked users',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Users you block will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
