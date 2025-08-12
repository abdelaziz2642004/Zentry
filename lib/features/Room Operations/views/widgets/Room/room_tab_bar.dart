import 'package:flutter/material.dart';

class RoomTabBar extends StatelessWidget {
  const RoomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        labelColor: Colors.blue[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[600],
        tabs: const [
          Tab(icon: Icon(Icons.room), text: 'Room'),
          Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
        ],
      ),
    );
  }
}
