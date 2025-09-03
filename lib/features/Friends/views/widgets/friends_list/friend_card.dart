import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/models/friend.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/block_service.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/views/screens/chat_screen.dart';

class FriendCard extends StatefulWidget {
  final Friend friend;
  final VoidCallback onRemove;
  final VoidCallback? onBlock;

  const FriendCard({
    super.key,
    required this.friend,
    required this.onRemove,
    this.onBlock,
  });

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {
  final BlockService _blockService = BlockService();
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _checkBlockStatus();
  }

  Future<void> _checkBlockStatus() async {
    try {
      final isBlocked = await _blockService.isUserBlocked(widget.friend.id);
      if (mounted) {
        setState(() {
          _isBlocked = isBlocked;
        });
      }
    } catch (e) {
      print('Error checking block status: $e');
    }
  }

  Future<void> _handleBlockAction() async {
    try {
      if (_isBlocked) {
        await _blockService.unblockUser(widget.friend.id);
        setState(() {
          _isBlocked = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.friend.fullName} has been unblocked',
                style: const TextStyle(color: Color(0xFFD9F5F0)),
              ),
              backgroundColor: const Color(0xFF2CACAD),
            ),
          );
        }
      } else {
        await _blockService.blockUser(widget.friend.id);
        setState(() {
          _isBlocked = true;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.friend.fullName} has been blocked',
                style: const TextStyle(color: Color(0xFFD9F5F0)),
              ),
              backgroundColor: const Color(0xFF072E33),
            ),
          );
        }
      }
      widget.onBlock?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${_isBlocked ? 'unblocking' : 'blocking'} user: $e',
              style: const TextStyle(color: Color(0xFFD9F5F0)),
            ),
            backgroundColor: const Color(0xFF072E33),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                border: Border.all(
                  color: const Color(0xFF2CACAD).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2CACAD).withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 1.2,
                            colors: [
                              const Color(0xFF2CACAD).withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Enhanced avatar with status
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            widget.friend.isOnline
                                                ? const Color(0xFF2CACAD)
                                                : const Color(
                                                  0xFF2CACAD,
                                                ).withOpacity(0.3),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              widget.friend.isOnline
                                                  ? const Color(
                                                    0xFF2CACAD,
                                                  ).withOpacity(0.4)
                                                  : Colors.transparent,
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: const Color(
                                        0xFF2CACAD,
                                      ).withOpacity(0.2),
                                      child: Text(
                                        widget.friend.fullName.isNotEmpty
                                            ? widget.friend.fullName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2CACAD),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Online status indicator
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color:
                                            widget.friend.isOnline
                                                ? const Color(0xFF0F9E9C)
                                                : const Color(0xFF072E33),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF05161A),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          if (widget.friend.isOnline)
                                            BoxShadow(
                                              color: const Color(
                                                0xFF0F9E9C,
                                              ).withOpacity(0.6),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 16),

                              // Friend info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.friend.fullName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD9F5F0),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '@${widget.friend.username}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(
                                          0xFF2CACAD,
                                        ).withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                widget.friend.isOnline
                                                    ? const Color(
                                                      0xFF0F9E9C,
                                                    ).withOpacity(0.2)
                                                    : const Color(
                                                      0xFF072E33,
                                                    ).withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  widget.friend.isOnline
                                                      ? const Color(
                                                        0xFF0F9E9C,
                                                      ).withOpacity(0.4)
                                                      : const Color(
                                                        0xFF2CACAD,
                                                      ).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            widget.friend.isOnline
                                                ? 'Online'
                                                : 'Offline',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  widget.friend.isOnline
                                                      ? const Color(0xFF0F9E9C)
                                                      : const Color(
                                                        0xFFD9F5F0,
                                                      ).withOpacity(0.6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Quick action buttons
                              Column(
                                children: [
                                  _buildQuickActionButton(
                                    icon: Icons.chat_bubble_outline,
                                    onPressed: () => _navigateToChat(context),
                                    tooltip: 'Chat',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildQuickActionButton(
                                    icon:
                                        _isBlocked
                                            ? Icons.person_add
                                            : Icons.person_remove,
                                    onPressed: _handleBlockAction,
                                    tooltip: _isBlocked ? 'Unblock' : 'Block',
                                    isDestructive: !_isBlocked,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDestructive
                    ? [
                      const Color(0xFF072E33).withOpacity(0.8),
                      const Color(0xFF05161A).withOpacity(0.9),
                    ]
                    : [
                      const Color(0xFF2CACAD).withOpacity(0.2),
                      const Color(0xFF0F9E9C).withOpacity(0.1),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isDestructive
                    ? const Color(0xFF2CACAD).withOpacity(0.3)
                    : const Color(0xFF2CACAD).withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Icon(
              icon,
              size: 18,
              color:
                  isDestructive
                      ? const Color(0xFFD9F5F0).withOpacity(0.7)
                      : const Color(0xFF2CACAD),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (_) => ChatCubit()..loadChatMessages(widget.friend.id),
              child: ChatScreen(
                otherUserId: widget.friend.id,
                otherUserName: widget.friend.fullName,
              ),
            ),
      ),
    );
  }
}
