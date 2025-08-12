import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/daily_study_service.dart';

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Today,", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(_todayDate, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          _isLoading
              ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              )
              : Column(
                children: [
                  Text(
                    TimezoneUtils.formatDuration(_dailyStudyTime),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        "Live tracking",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
