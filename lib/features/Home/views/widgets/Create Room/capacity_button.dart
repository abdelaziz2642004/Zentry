import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/custom_container.dart';

class CapacityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CapacityButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: CustomContainer(
          color: secondaryColor,
          hPadding: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: white),
          ),
        ),
      ),
    );
  }
}
