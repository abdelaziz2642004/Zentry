import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/daily_study_service.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/views/screens/leaderboard_screen.dart';

class Timetrackertoday extends StatefulWidget {
  const Timetrackertoday({super.key});

  @override
  State<Timetrackertoday> createState() => _TimetrackertodayState();
}

class _TimetrackertodayState extends State<Timetrackertoday> {
  final DailyStudyService _studyService = DailyStudyService();
  Duration _dailyStudyTime = Duration.zero;
  String _todayDate = '';
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDailyStudyTime();
    _todayDate = TimezoneUtils.getTodayDateString();

    // Refresh study time every 30 seconds to show real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadDailyStudyTime();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDailyStudyTime() async {
    try {
      final studyTime = await _studyService.getDailyStudyTime();
      if (mounted) {
        setState(() {
          _dailyStudyTime = studyTime;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      e;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF05161A), Color(0xFF072E33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2CACAD), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2CACAD).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2CACAD).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0F9E9C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with date and leaderboard button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2CACAD).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2CACAD).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.today,
                            color: const Color(0xFF75E2E0),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Today, ",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD9F5F0),
                            ),
                          ),
                          Text(
                            _todayDate,
                            style: const TextStyle(
                              color: Color(0xFF75E2E0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Leaderboard button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9E9C), Color(0xFF0C7075)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0F9E9C,
                            ).withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.leaderboard,
                          color: Color(0xFFD9F5F0),
                          size: 18,
                        ),
                        tooltip: 'View Leaderboard',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Study time display
                _isLoading
                    ? Container(
                      padding: const EdgeInsets.all(20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF75E2E0),
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        // Main time display
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2CACAD).withValues(alpha: 0.2),
                                Color(0xFF0F9E9C).withValues(alpha: 0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFF2CACAD).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Time text
                              Text(
                                TimezoneUtils.formatDuration(_dailyStudyTime),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD9F5F0),
                                  fontFamily: 'monospace',
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Live tracking indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(
                                    0xFF0F9E9C,
                                  ).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF0F9E9C),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0F9E9C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Live tracking",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF0F9E9C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}
