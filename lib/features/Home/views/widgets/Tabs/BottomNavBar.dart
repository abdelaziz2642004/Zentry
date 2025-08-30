import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class Bottomnavbar extends StatelessWidget {
  const Bottomnavbar({super.key, required int index, required this.rebuild})
    : _index = index;
  final void Function(int)? rebuild;

  final int _index;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _index,
      onTap: rebuild,
      selectedItemColor: const Color.fromARGB(255, 255, 152, 0),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: [
        _buildNavItem(Icons.home, 0),
        _buildNavItem(Icons.people, 1),
        _buildNavItem(Icons.groups, 2),
        _buildNavItem(Icons.chat, 3),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: _index == index ? mainColor : Colors.grey),
          const SizedBox(height: 45),
          if (_index == index)
            Positioned(
              bottom: 0,
              child: Container(
                width: 12,
                height: 6,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
        ],
      ),
      label: '',
    );
  }
}
