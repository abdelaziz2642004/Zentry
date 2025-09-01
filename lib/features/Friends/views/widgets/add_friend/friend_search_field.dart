import 'package:flutter/material.dart';

class FriendSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onSearchChanged;

  const FriendSearchField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Search by friend code',
        hintText: 'Enter 6-character friend code',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: onSearchChanged,
    );
  }
}
