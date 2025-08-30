import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

class JoinPrivateGroupDialog extends StatefulWidget {
  final StudyGroup group;
  final Function(String password) onJoin;

  const JoinPrivateGroupDialog({
    super.key,
    required this.group,
    required this.onJoin,
  });

  @override
  State<JoinPrivateGroupDialog> createState() => _JoinPrivateGroupDialogState();
}

class _JoinPrivateGroupDialogState extends State<JoinPrivateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Join ${widget.group.name}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This is a private group. Please enter the password to join.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                hintText: 'Enter group password',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onJoin(_passwordController.text.trim());
              Navigator.of(context).pop();
            }
          },
          child: const Text('Join'),
        ),
      ],
    );
  }
}
