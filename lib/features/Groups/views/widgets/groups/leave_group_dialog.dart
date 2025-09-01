import 'package:flutter/material.dart';

class LeaveGroupDialog extends StatelessWidget {
  final String groupName;
  final VoidCallback onLeave;

  const LeaveGroupDialog({
    super.key,
    required this.groupName,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Leave Group'),
      content: Text('Are you sure you want to leave "$groupName"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onLeave();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Leave'),
        ),
      ],
    );
  }
}
