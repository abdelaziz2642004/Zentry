import 'package:flutter/material.dart';

class FriendMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool showInput;

  const FriendMessageInput({
    super.key,
    required this.controller,
    required this.showInput,
  });

  @override
  Widget build(BuildContext context) {
    if (!showInput) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Message (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
