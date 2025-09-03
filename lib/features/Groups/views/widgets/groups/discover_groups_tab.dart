import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/discovery_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_states.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/groups/group_card_with_membership.dart';

class DiscoverGroupsTab extends StatelessWidget {
  final Function(dynamic) onJoinGroup;
  final Function(dynamic) onJoinPrivateGroup;
  final Function(dynamic) onNavigateToChat;

  const DiscoverGroupsTab({
    super.key,
    required this.onJoinGroup,
    required this.onJoinPrivateGroup,
    required this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryGroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is PublicGroupsLoadingState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF2CACAD),
                  ),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Discovering study groups...',
                  style: TextStyle(
                    color: const Color(0xFFD9F5F0).withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is PublicGroupsLoadedState) {
          final groups = state.groups;
          if (groups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DiscoveryGroupsCubit>().loadPublicGroups();
            },
            color: const Color(0xFF2CACAD),
            backgroundColor: const Color(0xFF072E33),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                12,
                16,
                12,
                100,
              ), // Bottom padding for FAB
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85, // Reduced height for more compact cards
              ),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 80)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: GroupCardWithMembership(
                            group: group,
                            onJoin: () {
                              if (group.isPrivate) {
                                onJoinPrivateGroup(group);
                              } else {
                                onJoinGroup(group);
                              }
                            },
                            onChat:
                                (isMember) =>
                                    isMember ? onNavigateToChat(group) : null,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        if (state is GroupsErrorState) {
          return _buildErrorState(context, state.error);
        }

        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF2CACAD)),
            strokeWidth: 3,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 8),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, animValue, child) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF05161A).withOpacity(0.95),
                            const Color(0xFF072E33).withOpacity(0.9),
                            const Color(0xFF0C7075).withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: const [0.0, 0.6, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFF2CACAD).withOpacity(
                            0.4 + (0.2 * math.sin(animValue * 2 * math.pi)),
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2CACAD).withOpacity(0.15),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(0xFF2CACAD).withOpacity(
                              0.08 + (0.05 * math.sin(animValue * 3 * math.pi)),
                            ),
                            blurRadius: 50,
                            spreadRadius: 8,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background floating particles
                          ...List.generate(5, (index) {
                            final particleOffset =
                                (animValue + index * 0.2) % 1.0;
                            return Positioned(
                              left:
                                  30 +
                                  (index * 50) +
                                  (20 * math.sin(particleOffset * 2 * math.pi)),
                              top:
                                  40 +
                                  (index * 30) +
                                  (15 *
                                      math.cos(particleOffset * 2.5 * math.pi)),
                              child: Opacity(
                                opacity:
                                    0.2 +
                                    (0.1 *
                                        math.sin(particleOffset * 4 * math.pi)),
                                child: Container(
                                  width:
                                      3 +
                                      (1 *
                                          math.sin(
                                            particleOffset * 6 * math.pi,
                                          )),
                                  height:
                                      3 +
                                      (1 *
                                          math.sin(
                                            particleOffset * 6 * math.pi,
                                          )),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2CACAD),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2CACAD,
                                        ).withOpacity(0.4),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Main content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Ultra-modern animated icon with morphing effects
                              TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 4),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, pulseValue, child) {
                                  return Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment(
                                          0.2 *
                                              math.sin(
                                                pulseValue * 2 * math.pi,
                                              ),
                                          0.2 *
                                              math.cos(
                                                pulseValue * 2 * math.pi,
                                              ),
                                        ),
                                        radius:
                                            1.2 +
                                            (0.3 *
                                                math.sin(
                                                  pulseValue * 3 * math.pi,
                                                )),
                                        colors: [
                                          const Color(
                                            0xFF2CACAD,
                                          ).withOpacity(0.25),
                                          const Color(
                                            0xFF0F9E9C,
                                          ).withOpacity(0.15),
                                          const Color(
                                            0xFF2CACAD,
                                          ).withOpacity(0.05),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.3, 0.6, 1.0],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF2CACAD,
                                          ).withOpacity(
                                            0.3 +
                                                (0.2 *
                                                    math.sin(
                                                      pulseValue * 2 * math.pi,
                                                    )),
                                          ),
                                          blurRadius:
                                              30 +
                                              (15 *
                                                  math.sin(
                                                    pulseValue * 2 * math.pi,
                                                  )),
                                          spreadRadius:
                                              5 +
                                              (5 *
                                                  math.sin(
                                                    pulseValue * 2 * math.pi,
                                                  )),
                                        ),
                                        BoxShadow(
                                          color: const Color(
                                            0xFF0F9E9C,
                                          ).withOpacity(
                                            0.2 +
                                                (0.1 *
                                                    math.sin(
                                                      pulseValue * 3 * math.pi,
                                                    )),
                                          ),
                                          blurRadius: 50,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Transform.scale(
                                      scale:
                                          1.0 +
                                          (0.1 *
                                              math.sin(
                                                pulseValue * 4 * math.pi,
                                              )),
                                      child: Transform.rotate(
                                        angle: pulseValue * 0.2,
                                        child: Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 80,
                                          color: const Color(
                                            0xFF2CACAD,
                                          ).withOpacity(0.9),
                                          shadows: [
                                            Shadow(
                                              color: const Color(
                                                0xFF2CACAD,
                                              ).withOpacity(0.5),
                                              offset: const Offset(0, 4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 32),

                              // Enhanced title with gradient text effect
                              ShaderMask(
                                shaderCallback:
                                    (bounds) => LinearGradient(
                                      colors: [
                                        const Color(0xFFD9F5F0),
                                        const Color(0xFF2CACAD),
                                        const Color(0xFFD9F5F0),
                                      ],
                                      stops: [
                                        0.0,
                                        0.5 +
                                            (0.3 *
                                                math.sin(
                                                  animValue * 2 * math.pi,
                                                )),
                                        1.0,
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  '✨ No Study Groups Found',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: const Color(
                                          0xFF2CACAD,
                                        ).withOpacity(0.3),
                                        offset: const Offset(0, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Enhanced description with better typography
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  'Ready to start your learning journey? 🚀\nCreate an amazing study community and connect with passionate learners worldwide!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(
                                      0xFFD9F5F0,
                                    ).withOpacity(0.8),
                                    height: 1.6,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 36),

                              // Ultra-modern call to action button with advanced effects
                              TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 3),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, btnAnim, child) {
                                  return Transform.scale(
                                    scale:
                                        1.0 +
                                        (0.05 *
                                            math.sin(btnAnim * 3 * math.pi)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF2CACAD),
                                            const Color(0xFF0F9E9C),
                                            const Color(0xFF2CACAD),
                                          ],
                                          stops: [
                                            0.0,
                                            0.5 +
                                                (0.3 *
                                                    math.sin(
                                                      btnAnim * 2 * math.pi,
                                                    )),
                                            1.0,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF2CACAD,
                                            ).withOpacity(0.4),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 6),
                                          ),
                                          BoxShadow(
                                            color: const Color(
                                              0xFF0F9E9C,
                                            ).withOpacity(
                                              0.3 +
                                                  (0.2 *
                                                      math.sin(
                                                        btnAnim * 4 * math.pi,
                                                      )),
                                            ),
                                            blurRadius: 25,
                                            spreadRadius: 4,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            // TODO: Navigate to create group
                                          },
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 16,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Transform.scale(
                                                  scale:
                                                      1.0 +
                                                      (0.1 *
                                                          math.sin(
                                                            btnAnim *
                                                                5 *
                                                                math.pi,
                                                          )),
                                                  child: Icon(
                                                    Icons.add_circle_rounded,
                                                    color: const Color(
                                                      0xFF05161A,
                                                    ),
                                                    size: 24,
                                                    shadows: [
                                                      Shadow(
                                                        color: const Color(
                                                          0xFF05161A,
                                                        ).withOpacity(0.3),
                                                        offset: const Offset(
                                                          0,
                                                          1,
                                                        ),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Create Your Group',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color(
                                                      0xFF05161A,
                                                    ),
                                                    letterSpacing: 0.5,
                                                    shadows: [
                                                      Shadow(
                                                        color: const Color(
                                                          0xFF05161A,
                                                        ).withOpacity(0.2),
                                                        offset: const Offset(
                                                          0,
                                                          1,
                                                        ),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Additional inspirational text
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2CACAD,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF2CACAD,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline_rounded,
                                      size: 18,
                                      color: const Color(0xFF2CACAD),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Be the first to build an amazing study community!',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2CACAD),
                                          letterSpacing: 0.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildErrorState(BuildContext context, String error) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF05161A).withOpacity(0.8),
                      const Color(0xFF072E33).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF2CACAD).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF072E33).withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2CACAD).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: const Color(0xFFD9F5F0).withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      '⚠️ Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD9F5F0),
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      error,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFD9F5F0).withOpacity(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Retry button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2CACAD).withOpacity(0.8),
                            const Color(0xFF0F9E9C).withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2CACAD).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context
                                .read<DiscoveryGroupsCubit>()
                                .loadPublicGroups();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  color: const Color(0xFF05161A),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Try Again',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF05161A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
}
