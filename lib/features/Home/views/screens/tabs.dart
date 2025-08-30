// hello
import 'package:flutter/material.dart';

import 'package:zentry_pomodoro_app/features/Home/views/screens/home_screen.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Tabs/BottomNavBar.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/screens/friends_screen.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/screens/groups_screen.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/screens/chat_list_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsState();
}

class _TabsState extends State<TabsScreen> {
  int _index = 0;

  void rebuild(int index) {
    setState(() {
      _index = index;
    });
  }

  Widget _buildScreenChooser(int index, void Function(int) rebuild) {
    switch (index) {
      case 0:
        return const Homescreen();
      case 1:
        return const FriendsScreen();
      case 2:
        return const GroupsScreen();
      case 3:
        return const ChatListScreen();
      default:
        return const Homescreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget buildScreen = _buildScreenChooser(_index, rebuild);

    return SafeArea(
      child: Scaffold(
        body: buildScreen,
        bottomNavigationBar: Bottomnavbar(index: _index, rebuild: rebuild),
      ),
    );
  }
}
