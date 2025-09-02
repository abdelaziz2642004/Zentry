import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/viewmodels/study_tracking_cubit.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/views/screens/StudyCalendarScreen.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/views/screens/StudyStatsScreen.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/views/screens/leaderboard_screen.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced stats buttons grid with staggered animations (no header)
          _buildAnimatedStatsGrid(context),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatsGrid(BuildContext context) {
    return Row(
      children: [
        // Study Calendar Button with enhanced design
        Expanded(
          child: _buildAnimatedStatCard(
            context: context,
            delay: 0,
            icon: Icons.calendar_month,
            title: "Calendar",
            subtitle: "Track progress",
            gradient: const LinearGradient(
              colors: [Color(0xFF2CACAD), Color(0xFF0F9E9C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudyCalendarScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 6),

        // Study Stats Button with enhanced design
        Expanded(
          child: _buildAnimatedStatCard(
            context: context,
            delay: 200,
            icon: Icons.analytics,
            title: "Analytics",
            subtitle: "View insights",
            gradient: const LinearGradient(
              colors: [Color(0xFF0F9E9C), Color(0xFF0C7075)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BlocProvider<StudyTrackingCubit>(
                        create: (context) => StudyTrackingCubit(),
                        child: const StudyStatsScreen(),
                      ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 6),

        // Leaderboard Button with enhanced design
        Expanded(
          child: _buildAnimatedStatCard(
            context: context,
            delay: 400,
            icon: Icons.leaderboard,
            title: "Leaderboard",
            subtitle: "See rankings",
            gradient: const LinearGradient(
              colors: [Color(0xFF2CACAD), Color(0xFF0F9E9C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedStatCard({
    required BuildContext context,
    required int delay,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Enhanced icon container with animation
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1000 + delay),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, iconValue, child) {
                              return Transform.scale(
                                scale: iconValue,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD9F5F0,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFD9F5F0,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFD9F5F0,
                                        ).withOpacity(0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    icon,
                                    color: const Color(0xFFD9F5F0),
                                    size: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),

                          // Enhanced title with animation
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1200 + delay),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, titleValue, child) {
                              return Transform.translate(
                                offset: Offset(0, 10 * (1 - titleValue)),
                                child: Opacity(
                                  opacity: titleValue,
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      color: Color(0xFFD9F5F0),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 2),

                          // Enhanced subtitle with animation
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1400 + delay),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, subtitleValue, child) {
                              return Transform.translate(
                                offset: Offset(0, 15 * (1 - subtitleValue)),
                                child: Opacity(
                                  opacity: subtitleValue,
                                  child: Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFD9F5F0,
                                      ).withOpacity(0.8),
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 0.1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
