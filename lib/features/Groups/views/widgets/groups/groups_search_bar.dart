import 'package:flutter/material.dart';

class GroupsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;

  const GroupsSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF05161A).withOpacity(0.9),
            const Color(0xFF072E33).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFFD9F5F0)),
        decoration: InputDecoration(
          hintText: 'Search groups...',
          hintStyle: TextStyle(color: const Color(0xFFD9F5F0).withOpacity(0.6)),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF2CACAD).withOpacity(0.8),
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
            borderSide: const BorderSide(color: Color(0xFF2CACAD), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}
