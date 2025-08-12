import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/create_button.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/room_control.dart';

class CreateRoomButtonRow extends StatelessWidget {
  final bool isPrivate;
  final VoidCallback onTogglePrivate;
  final VoidCallback onCreate;

  const CreateRoomButtonRow({
    super.key,
    required this.isPrivate,
    required this.onTogglePrivate,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoomControl(isPrivate: isPrivate, onToggle: onTogglePrivate),
        CreateButton(onPressed: onCreate),
      ],
    );
  }
}
