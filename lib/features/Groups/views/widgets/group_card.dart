import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/data/models/study_group.dart';

class GroupCard extends StatelessWidget {
  final StudyGroup group;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onChat;
  final bool isUserMember;

  const GroupCard({
    super.key,
    required this.group,
    this.onJoin,
    this.onLeave,
    this.onChat,
    this.isUserMember = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 6),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, animValue, child) {
                  return GestureDetector(
                    onTapDown: (_) {
                      // TODO: Add haptic feedback
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF05161A).withOpacity(0.98),
                            const Color(0xFF072E33).withOpacity(0.95),
                            const Color(0xFF0C7075).withOpacity(0.92),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 0.6, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              isUserMember
                                  ? const Color(0xFF0F9E9C).withOpacity(
                                    0.6 +
                                        (0.2 *
                                            math.sin(animValue * 2 * math.pi)),
                                  )
                                  : const Color(0xFF2CACAD).withOpacity(
                                    0.5 +
                                        (0.1 *
                                            math.sin(animValue * 3 * math.pi)),
                                  ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isUserMember
                                    ? const Color(0xFF0F9E9C).withOpacity(0.3)
                                    : const Color(0xFF2CACAD).withOpacity(0.25),
                            blurRadius: 20,
                            spreadRadius: 3,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color:
                                isUserMember
                                    ? const Color(0xFF0F9E9C).withOpacity(
                                      0.15 +
                                          (0.1 *
                                              math.sin(
                                                animValue * 4 * math.pi,
                                              )),
                                    )
                                    : const Color(0xFF2CACAD).withOpacity(
                                      0.1 +
                                          (0.05 *
                                              math.sin(
                                                animValue * 4 * math.pi,
                                              )),
                                    ),
                            blurRadius: 40,
                            spreadRadius: 5,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Advanced animated background pattern
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment(
                                      0.3 +
                                          (0.2 *
                                              math.sin(
                                                animValue * 2 * math.pi,
                                              )),
                                      -0.4 +
                                          (0.3 *
                                              math.cos(
                                                animValue * 1.5 * math.pi,
                                              )),
                                    ),
                                    radius:
                                        1.5 +
                                        (0.2 *
                                            math.sin(animValue * 3 * math.pi)),
                                    colors: [
                                      isUserMember
                                          ? const Color(
                                            0xFF0F9E9C,
                                          ).withOpacity(0.12)
                                          : const Color(
                                            0xFF2CACAD,
                                          ).withOpacity(0.1),
                                      const Color(0xFF072E33).withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.4, 1.0],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Floating micro-particles
                                    ...List.generate(3, (index) {
                                      final particleOffset =
                                          (animValue + index * 0.33) % 1.0;
                                      return Positioned(
                                        left:
                                            20 +
                                            (index * 60) +
                                            (15 *
                                                math.sin(
                                                  particleOffset * 2 * math.pi,
                                                )),
                                        top:
                                            30 +
                                            (index * 40) +
                                            (10 *
                                                math.cos(
                                                  particleOffset * 3 * math.pi,
                                                )),
                                        child: Opacity(
                                          opacity:
                                              0.3 +
                                              (0.2 *
                                                  math.sin(
                                                    particleOffset *
                                                        4 *
                                                        math.pi,
                                                  )),
                                          child: Container(
                                            width:
                                                2 +
                                                (1 *
                                                    math.sin(
                                                      particleOffset *
                                                          5 *
                                                          math.pi,
                                                    )),
                                            height:
                                                2 +
                                                (1 *
                                                    math.sin(
                                                      particleOffset *
                                                          5 *
                                                          math.pi,
                                                    )),
                                            decoration: BoxDecoration(
                                              color:
                                                  isUserMember
                                                      ? const Color(0xFF0F9E9C)
                                                      : const Color(0xFF2CACAD),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (isUserMember
                                                          ? const Color(
                                                            0xFF0F9E9C,
                                                          )
                                                          : const Color(
                                                            0xFF2CACAD,
                                                          ))
                                                      .withOpacity(0.4),
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            // Ultra-modern member badge with morphing effects
                            if (isUserMember)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: TweenAnimationBuilder<double>(
                                  duration: const Duration(seconds: 2),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, badgeAnim, child) {
                                    return Transform.scale(
                                      scale:
                                          1.0 +
                                          (0.05 *
                                              math.sin(
                                                badgeAnim * 4 * math.pi,
                                              )),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF0F9E9C),
                                              const Color(0xFF2CACAD),
                                              const Color(0xFF0F9E9C),
                                            ],
                                            stops: [
                                              0.0,
                                              0.5 +
                                                  (0.3 *
                                                      math.sin(
                                                        badgeAnim * 3 * math.pi,
                                                      )),
                                              1.0,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF0F9E9C,
                                              ).withOpacity(0.4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 3),
                                            ),
                                            BoxShadow(
                                              color: const Color(
                                                0xFF0F9E9C,
                                              ).withOpacity(
                                                0.2 +
                                                    (0.1 *
                                                        math.sin(
                                                          badgeAnim *
                                                              2 *
                                                              math.pi,
                                                        )),
                                              ),
                                              blurRadius: 16,
                                              spreadRadius: 4,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Transform.rotate(
                                              angle: badgeAnim * 0.3,
                                              child: Icon(
                                                Icons.verified_rounded,
                                                size: 16,
                                                color: const Color(0xFF05161A),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Member',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF05161A),
                                                letterSpacing: 0.3,
                                                shadows: [
                                                  Shadow(
                                                    color: const Color(
                                                      0xFF2CACAD,
                                                    ).withOpacity(0.3),
                                                    offset: const Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // Private group indicator
                            if (!group.isPublic)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF072E33,
                                    ).withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF2CACAD,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.lock_rounded,
                                    size: 16,
                                    color: const Color(0xFF2CACAD),
                                  ),
                                ),
                              ),

                            // Ultra-compact main content for grid layout
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Group name - compact
                                  Text(
                                    group.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFD9F5F0),
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 6),

                                  // Description - more compact
                                  Text(
                                    group.description,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: const Color(
                                        0xFFD9F5F0,
                                      ).withOpacity(0.8),
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const Spacer(),

                                  // Compact stats row
                                  Row(
                                    children: [
                                      _buildCompactStatChip(
                                        Icons.people_rounded,
                                        '${group.memberCount}/${group.maxMembers}',
                                      ),
                                      const SizedBox(width: 4),
                                      _buildCompactStatChip(
                                        group.isPublic
                                            ? Icons.public_rounded
                                            : Icons.lock_rounded,
                                        group.isPublic ? 'Public' : 'Private',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  // Additional info row
                                  Row(
                                    children: [
                                      if (group.messageCount > 0)
                                        _buildCompactStatChip(
                                          Icons.chat_bubble_outline_rounded,
                                          '${group.messageCount}',
                                        ),
                                      if (group.messageCount > 0)
                                        const SizedBox(width: 4),
                                      if (group.creatorName.isNotEmpty)
                                        Expanded(
                                          child: _buildCompactStatChip(
                                            Icons.person_outline_rounded,
                                            group.creatorName,
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Compact action button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 32,
                                    child: ElevatedButton.icon(
                                      onPressed: isUserMember ? onChat : onJoin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isUserMember
                                                ? const Color(0xFF0F9E9C)
                                                : const Color(0xFF2CACAD),
                                        foregroundColor: const Color(
                                          0xFF05161A,
                                        ),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                      icon: Icon(
                                        isUserMember
                                            ? Icons.chat_bubble_rounded
                                            : Icons.add_rounded,
                                        size: 14,
                                      ),
                                      label: Text(
                                        isUserMember ? 'Chat' : 'Join',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF072E33).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2CACAD).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2CACAD)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD9F5F0).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF072E33).withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF2CACAD).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: const Color(0xFF2CACAD)),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD9F5F0).withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required bool isPrimary,
  }) {
    return Container(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? const Color(0xFF2CACAD) : const Color(0xFF072E33),
          foregroundColor:
              isPrimary ? const Color(0xFF05161A) : const Color(0xFFD9F5F0),
          elevation: isPrimary ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                isPrimary
                    ? BorderSide.none
                    : BorderSide(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                      width: 1,
                    ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
