import 'dart:math' as math;
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 8),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              // Ultra-modern search bar with morphing effects
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2CACAD).withOpacity(0.2),
                      const Color(0xFF0F9E9C).withOpacity(0.15),
                      const Color(0xFF2CACAD).withOpacity(0.18),
                    ],
                    stops: [
                      0.0,
                      0.5 + (0.2 * math.sin(animValue * 2 * math.pi)),
                      1.0,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF2CACAD).withOpacity(
                      0.4 + (0.2 * math.sin(animValue * 3 * math.pi)),
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(
                        0.08 + (0.05 * math.sin(animValue * 4 * math.pi)),
                      ),
                      blurRadius: 25,
                      spreadRadius: 5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Color(0xFFD9F5F0),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Discover study groups...',
                    hintStyle: TextStyle(
                      color: const Color(0xFFD9F5F0).withOpacity(0.6),
                      fontSize: 16,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.search_outlined,
                        color: const Color(0xFF2CACAD),
                        size: 20,
                      ),
                    ),
                    suffixIcon:
                        controller.text.isNotEmpty
                            ? IconButton(
                              onPressed: () {
                                controller.clear();
                                onSearchChanged('');
                              },
                              icon: Icon(
                                Icons.clear_rounded,
                                color: const Color(0xFFD9F5F0).withOpacity(0.7),
                                size: 20,
                              ),
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
