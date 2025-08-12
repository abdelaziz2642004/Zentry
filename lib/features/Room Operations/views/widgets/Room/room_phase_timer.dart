import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/study_session_tracker.dart';

class RoomPhaseTimer extends StatefulWidget {
  final DateTime createdAt;
  final int workDuration;
  final int breakDuration;
  final int totalSessions;

  const RoomPhaseTimer({
    super.key,
    required this.createdAt,
    required this.workDuration,
    required this.breakDuration,
    required this.totalSessions,
  });

  @override
  State<RoomPhaseTimer> createState() => _RoomPhaseTimerState();
}

class _RoomPhaseTimerState extends State<RoomPhaseTimer> {
  Timer? _timer;
  late int elapsedMinutes;
  String currentPhase = "";
  int timeInPhase = 0;
  String previousPhase = "";
  final StudySessionTracker _sessionTracker = StudySessionTracker();
  int _studyMinutesAdded = 0;

  void updatePhase() {
    final now = DateTime.now().toUtc(); // Use UTC for consistency
    final createdAt = widget.createdAt.toUtc(); // Convert to UTC
    final elapsed = now.difference(createdAt);
    elapsedMinutes = elapsed.inMinutes;

    final fullCycle = widget.workDuration + widget.breakDuration;
    final cyclesPassed = elapsedMinutes ~/ fullCycle;
    final remTime = elapsedMinutes % fullCycle;

    if (cyclesPassed >= widget.totalSessions) {
      setState(() {
        currentPhase = "Finished all sessions";
        timeInPhase = 0;
      });
      _timer?.cancel();
      _sessionTracker
          .stopWorkSession(); // Stop tracking when all sessions are done
      return;
    }

    if (remTime < widget.workDuration) {
      setState(() {
        currentPhase = "Work";
        timeInPhase = remTime;
      });

      // Start tracking work session if we just entered work phase
      if (previousPhase != "Work") {
        _sessionTracker.startWorkSession(widget.workDuration);
        _studyMinutesAdded = 0;
      }

      // Update study minutes added
      if (_sessionTracker.isTracking) {
        _studyMinutesAdded = _sessionTracker.lastMinuteAdded;
      }
    } else {
      setState(() {
        currentPhase = "Break";
        timeInPhase = remTime - widget.workDuration;
      });

      // Stop tracking work session if we just entered break phase
      if (previousPhase == "Work") {
        _sessionTracker.stopWorkSession();
      }
    }

    previousPhase = currentPhase;
  }

  @override
  void initState() {
    super.initState();
    updatePhase();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updatePhase();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sessionTracker.dispose(); // Clean up the session tracker
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Current Phase: $currentPhase"),
        Text("Minutes in Current Phase: $timeInPhase"),
        Text("Elapsed Time: $elapsedMinutes minutes"),
        if (_sessionTracker.isTracking) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Tracking study session",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Progress: ${_sessionTracker.elapsedTime.inMinutes}/${_sessionTracker.workDurationMinutes} minutes",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  "Study time added: $_studyMinutesAdded minutes",
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
