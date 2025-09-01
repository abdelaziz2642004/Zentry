import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class WeeklyStudyTimeDisplay extends StatefulWidget {
  const WeeklyStudyTimeDisplay({super.key});

  @override
  State<WeeklyStudyTimeDisplay> createState() => _WeeklyStudyTimeDisplayState();
}

class _WeeklyStudyTimeDisplayState extends State<WeeklyStudyTimeDisplay> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<DateTime, Duration> _weeklyData = {};
  bool _isLoading = true;
  Duration _totalWeeklyTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadWeeklyStudyData();
  }

  Future<void> _loadWeeklyStudyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current week's dates (Saturday to Friday)
      final now = DateTime.now();
      final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday

      // Calculate Saturday of current week (weekday 6)
      // If today is Saturday (6), use today
      // If today is Sunday (7), use yesterday (Saturday)
      // If today is Monday (1) to Friday (5), go back to previous Saturday
      final saturday = now.subtract(Duration(days: (currentWeekday + 1) % 7));

      final Map<DateTime, Duration> result = {};
      Duration totalTime = Duration.zero;

      // Get study data for each day of the week (Saturday to Friday)
      for (int i = 0; i < 7; i++) {
        final date = saturday.add(Duration(days: i));
        final dateString =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        try {
          final doc =
              await _firestore
                  .collection(FirebaseConstants.dailyStatsCollection)
                  .doc(user.uid)
                  .collection('dates')
                  .doc(dateString)
                  .get();

          if (doc.exists) {
            final data = doc.data();
            final studyTimeSeconds =
                data?[FirebaseConstants.totalStudyTimeField] ?? 0;
            final studyTime = Duration(seconds: studyTimeSeconds);
            result[date] = studyTime;
            totalTime += studyTime;
          } else {
            result[date] = Duration.zero;
          }
        } catch (e) {
          result[date] = Duration.zero;
        }
      }

      if (mounted) {
        setState(() {
          _weeklyData = result;
          _totalWeeklyTime = totalTime;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isToday(String day, DateTime now) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDay = weekdays[now.weekday - 1];
    return day == currentDay;
  }

  String _formatStudyTime(Duration duration) {
    if (duration.inMinutes == 0) return '0';
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    }
    return '${duration.inMinutes}m';
  }

  String _formatTotalTime(Duration duration) {
    if (duration.inMinutes == 0) return '0 minutes';
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '$hours hours';
    }
    return '${duration.inMinutes} minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: mainColor),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'This Week\'s Study Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Total: ${_formatTotalTime(_totalWeeklyTime)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: mainColor,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  // Days of the week header
                  Row(
                    children:
                        ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((
                          day,
                        ) {
                          final isToday = _isToday(day, DateTime.now());
                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: isToday ? mainColor : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 8),

                  // Study time bars
                  Row(
                    children: List.generate(7, (index) {
                      final now = DateTime.now();
                      final currentWeekday = now.weekday;
                      final saturday = now.subtract(
                        Duration(days: (currentWeekday + 1) % 7),
                      );
                      final date = saturday.add(Duration(days: index));
                      final studyTime = _weeklyData[date] ?? Duration.zero;
                      final isToday = _isToday(
                        [
                          'Sat',
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                        ][index],
                        now,
                      );
                      final isFuture = date.isAfter(now);

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: Column(
                            children: [
                              // Study time bar
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      isFuture
                                          ? Colors.grey[300]
                                          : studyTime.inMinutes > 0
                                          ? mainColor.withOpacity(0.7)
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      isToday
                                          ? Border.all(
                                            color: mainColor,
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child: Center(
                                  child: Text(
                                    _formatStudyTime(studyTime),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isFuture
                                              ? Colors.grey[600]
                                              : studyTime.inMinutes > 0
                                              ? Colors.white
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: mainColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Study time',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Future days',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
