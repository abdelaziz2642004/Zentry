import 'package:flutter/material.dart';

class JoinedUsers extends StatelessWidget {
  const JoinedUsers({
    super.key,
    required this.joinedUsers,
    required this.roomCapacity,
  });

  final int joinedUsers;
  final int roomCapacity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.people, size: 14, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          "$joinedUsers / $roomCapacity",
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
