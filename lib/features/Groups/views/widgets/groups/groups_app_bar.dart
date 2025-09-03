import 'dart:math' as math;
import 'package:flutter/material.dart';

class GroupsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCreateGroup;
  final TabController tabController;

  const GroupsAppBar({
    super.key,
    required this.onCreateGroup,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 8),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return AppBar(
          title: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, titleValue, child) {
              return Transform.translate(
                offset: Offset(-30 * (1 - titleValue), 0),
                child: Opacity(
                  opacity: titleValue,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated icon with morphing effects
                      TweenAnimationBuilder<double>(
                        duration: const Duration(seconds: 3),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, iconValue, child) {
                          return Transform.scale(
                            scale:
                                1.0 + (0.1 * math.sin(iconValue * 4 * math.pi)),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: Alignment(
                                    0.3 * math.sin(iconValue * 2 * math.pi),
                                    0.3 * math.cos(iconValue * 2 * math.pi),
                                  ),
                                  radius:
                                      1.0 +
                                      (0.2 * math.sin(iconValue * 3 * math.pi)),
                                  colors: [
                                    const Color(0xFF2CACAD).withOpacity(0.3),
                                    const Color(0xFF0F9E9C).withOpacity(0.15),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.6, 1.0],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2CACAD).withOpacity(
                                      0.2 +
                                          (0.1 *
                                              math.sin(
                                                iconValue * 2 * math.pi,
                                              )),
                                    ),
                                    blurRadius:
                                        8 +
                                        (4 * math.sin(iconValue * 2 * math.pi)),
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: iconValue * 0.1,
                                child: Icon(
                                  Icons.groups_2_rounded,
                                  color: const Color(0xFF2CACAD),
                                  size: 24,
                                  shadows: [
                                    Shadow(
                                      color: const Color(
                                        0xFF2CACAD,
                                      ).withOpacity(0.5),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 12),

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
                                0.5 + (0.3 * math.sin(animValue * 2 * math.pi)),
                                1.0,
                              ],
                            ).createShader(bounds),
                        child: Text(
                          'Study Groups',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: Colors.white,
                            letterSpacing: 0.8,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF2CACAD).withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                              Shadow(
                                color: const Color(0xFF05161A).withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF05161A).withOpacity(0.95),
                  const Color(0xFF072E33).withOpacity(0.9),
                  const Color(0xFF0C7075).withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.0,
                  0.5 + (0.2 * math.sin(animValue * 2 * math.pi)),
                  1.0,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF05161A).withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFD9F5F0)),
          automaticallyImplyLeading: false,
          actions: [
            // Ultra-modern create group button
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, actionValue, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * actionValue),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 4),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, pulseValue, child) {
                      return Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2CACAD).withOpacity(0.3),
                              const Color(0xFF0F9E9C).withOpacity(0.2),
                              const Color(0xFF2CACAD).withOpacity(0.25),
                            ],
                            stops: [
                              0.0,
                              0.5 + (0.3 * math.sin(pulseValue * 2 * math.pi)),
                              1.0,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2CACAD).withOpacity(
                              0.4 + (0.2 * math.sin(pulseValue * 3 * math.pi)),
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2CACAD).withOpacity(0.2),
                              blurRadius:
                                  12 + (6 * math.sin(pulseValue * 2 * math.pi)),
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: const Color(0xFF0F9E9C).withOpacity(
                                0.1 +
                                    (0.05 * math.sin(pulseValue * 4 * math.pi)),
                              ),
                              blurRadius: 20,
                              spreadRadius: 4,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onCreateGroup,
                            borderRadius: BorderRadius.circular(16),
                            splashColor: const Color(
                              0xFF2CACAD,
                            ).withOpacity(0.2),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Transform.scale(
                                scale:
                                    1.0 +
                                    (0.05 * math.sin(pulseValue * 5 * math.pi)),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: const Color(0xFFD9F5F0),
                                  size: 22,
                                  shadows: [
                                    Shadow(
                                      color: const Color(
                                        0xFF2CACAD,
                                      ).withOpacity(0.4),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
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
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF05161A).withOpacity(0.8),
                    const Color(0xFF072E33).withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF2CACAD).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: tabController,
                labelColor: const Color(0xFF2CACAD),
                unselectedLabelColor: const Color(0xFFD9F5F0).withOpacity(0.6),
                indicatorColor: const Color(0xFF2CACAD),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: const Color(0xFF2CACAD),
                    width: 3,
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 16),
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          size: 18,
                          color:
                              tabController.index == 0
                                  ? const Color(0xFF2CACAD)
                                  : const Color(0xFFD9F5F0).withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        const Text('Discover'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 18,
                          color:
                              tabController.index == 1
                                  ? const Color(0xFF2CACAD)
                                  : const Color(0xFFD9F5F0).withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        const Text('My Groups'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
}
