import 'package:flutter/material.dart';
import '../../../../../../core/colors.dart';

class RoomName extends StatelessWidget {
  const RoomName({super.key, required this.roomName});

  final String roomName;

  @override
  Widget build(BuildContext context) {
    return Text(
      roomName,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: black,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
