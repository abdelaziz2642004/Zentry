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
      backgroundColor: const Color(0xFF05161A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF2CACAD).withOpacity(0.3),
          width: 1,
        ),
      ),
      title: Text(
        'Join ${widget.group.name}',
        style: const TextStyle(
          color: Color(0xFFD9F5F0),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF05161A).withOpacity(0.9),
              const Color(0xFF072E33).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This is a private group. Please enter the password to join.',
                style: TextStyle(
                  color: const Color(0xFFD9F5F0).withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Color(0xFFD9F5F0)),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: const Color(0xFF2CACAD).withOpacity(0.8),
                  ),
                  hintText: 'Enter group password',
                  hintStyle: TextStyle(
                    color: const Color(0xFFD9F5F0).withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2CACAD).withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2CACAD),
                      width: 2,
                    ),
                  ),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.7)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onJoin(_passwordController.text.trim());
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2CACAD),
            foregroundColor: const Color(0xFF05161A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Join',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
