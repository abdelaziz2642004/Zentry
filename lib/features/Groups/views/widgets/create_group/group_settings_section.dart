import 'package:flutter/material.dart';

class GroupSettingsSection extends StatelessWidget {
  final TextEditingController maxMembersController;
  final bool isPublic;
  final TextEditingController passwordController;
  final Function(bool) onPrivacyChanged;

  const GroupSettingsSection({
    super.key,
    required this.maxMembersController,
    required this.isPublic,
    required this.passwordController,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: maxMembersController,
          decoration: const InputDecoration(
            labelText: 'Max Members',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter max members';
            }
            final number = int.tryParse(value);
            if (number == null || number < 2 || number > 100) {
              return 'Max members must be between 2 and 100';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Public Group'),
          subtitle: const Text('Anyone can find and join this group'),
          value: isPublic,
          onChanged: onPrivacyChanged,
        ),
        if (!isPublic) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Group Password',
              border: OutlineInputBorder(),
              hintText: 'Enter password for private group',
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required for private groups';
              }
              if (value.trim().length < 4) {
                return 'Password must be at least 4 characters';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
