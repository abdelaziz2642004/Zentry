import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/study_session_tracker.dart';

class CircularTimerWidget extends StatefulWidget {
  const CircularTimerWidget({super.key});

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  int elapsedMinutes = 0;
  String currentPhase = "Loading...";
  int timeInPhase = 0;
  int timeInPhaseSeconds = 0; // Add seconds variable
  String previousPhase = "";
  final StudySessionTracker _sessionTracker = StudySessionTracker();
  int _studyMinutesAdded = 0;

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Slower, more subtle pulsing animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // More subtle scale range
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    // Initialize progress to 0
    _progressController.value = 0.0;
  }

  void _startTimer(
    DateTime roomCreatedAt,
    int workDuration,
    int breakDuration,
    int totalSessions,
  ) {
    // Cancel existing timer if any
    _timer?.cancel();

    print(
      'Starting timer with: work=$workDuration, break=$breakDuration, sessions=$totalSessions',
    );
    print('Room created at: $roomCreatedAt');

    // Initial update
    _updatePhase(roomCreatedAt, workDuration, breakDuration, totalSessions);

    // Start periodic updates
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updatePhase(roomCreatedAt, workDuration, breakDuration, totalSessions);
      }
    });
  }

  void _updatePhase(
    DateTime roomCreatedAt,
    int workDuration,
    int breakDuration,
    int totalSessions,
  ) {
    if (!mounted) return;

    final now = DateTime.now();
    final elapsed = now.difference(roomCreatedAt);
    elapsedMinutes = elapsed.inMinutes;
    final elapsedSeconds = elapsed.inSeconds;

    final fullCycle = workDuration + breakDuration;
    final cyclesPassed = elapsedMinutes ~/ fullCycle;
    final remTime = fullCycle - (elapsedMinutes % fullCycle);

    if (cyclesPassed >= totalSessions) {
      setState(() {
        currentPhase = "All Sessions Complete";
        timeInPhase = 0;
        timeInPhaseSeconds = 0;
      });
      _timer?.cancel();
      _sessionTracker.stopWorkSession();
      return;
    }

    if (remTime > breakDuration) {
      // Work Phase
      final workTimeRemaining = remTime - breakDuration;
      // Calculate seconds remaining in work phase with real-time precision
      final workPhaseStartTime =
          elapsedSeconds - (elapsedSeconds % (fullCycle * 60));
      final workPhaseElapsedSeconds = elapsedSeconds - workPhaseStartTime;
      final workTimeRemainingSeconds =
          (workDuration * 60) - workPhaseElapsedSeconds;

      setState(() {
        currentPhase = "Work Phase";
        timeInPhase = workTimeRemaining;
        timeInPhaseSeconds = workTimeRemainingSeconds.clamp(
          0,
          workDuration * 60,
        );
      });

      if (previousPhase != "Work") {
        _sessionTracker.startWorkSession(workDuration);
        _studyMinutesAdded = 0;
      }

      if (_sessionTracker.isTracking) {
        _studyMinutesAdded = _sessionTracker.lastMinuteAdded;
      }
    } else {
      // Break Phase
      // Calculate seconds remaining in break phase with real-time precision
      final breakPhaseStartTime =
          elapsedSeconds -
          (elapsedSeconds % (fullCycle * 60)) +
          (workDuration * 60);
      final breakPhaseElapsedSeconds = elapsedSeconds - breakPhaseStartTime;
      final breakTimeRemainingSeconds =
          (breakDuration * 60) - breakPhaseElapsedSeconds;

      setState(() {
        currentPhase = "Break Phase";
        timeInPhase = remTime;
        timeInPhaseSeconds = breakTimeRemainingSeconds.clamp(
          0,
          breakDuration * 60,
        );
      });

      if (previousPhase == "Work") {
        _sessionTracker.stopWorkSession();
      }
    }

    previousPhase = currentPhase;

    // Update progress animation with correct calculation
    final totalPhaseSeconds =
        currentPhase == "Work Phase" ? workDuration * 60 : breakDuration * 60;
    final progress = 1.0 - (timeInPhaseSeconds / totalPhaseSeconds);

    print(
      'Phase: $currentPhase, Time remaining: ${timeInPhase}m, Seconds: ${timeInPhaseSeconds}s, Progress: ${progress.toStringAsFixed(2)}',
    );

    _progressController.animateTo(progress);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sessionTracker.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomStates>(
      buildWhen: (previous, current) {
        return current is RoomJoinSuccess ||
            current is RoomUsersUpdated ||
            current is RoomJoinFailure ||
            current is RoomJoinLoadingState;
      },
      builder: (context, state) {
        if (state is RoomJoinLoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF75E2E0)),
            ),
          );
        } else if (state is RoomJoinSuccess || state is RoomUsersUpdated) {
          final roomDetails = (state as dynamic).room;

          print('Room details: ${roomDetails.toString()}');
          print('Work duration: ${roomDetails.workDuration}');
          print('Break duration: ${roomDetails.breakDuration}');
          print('Total sessions: ${roomDetails.totalSessions}');
          print('Created at: ${roomDetails.createdAt}');

          // Start timer with actual room data using post-frame callback
          if (_timer == null && roomDetails.createdAt != null) {
            final workDuration = roomDetails.workDuration ?? 25;
            final breakDuration = roomDetails.breakDuration ?? 5;
            final totalSessions = roomDetails.totalSessions ?? 4;
            final createdAt = roomDetails.createdAt.toDate();

            print('Starting timer...');
            // Use post-frame callback to avoid setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _startTimer(
                  createdAt,
                  workDuration,
                  breakDuration,
                  totalSessions,
                );
              }
            });
          }

          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Timer Circle
                SizedBox(
                  width: 280, // Increased from 250
                  height: 280, // Increased from 250
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Ring
                      CustomPaint(
                        size: const Size(280, 280), // Increased size
                        painter: CircularTimerPainter(
                          progress: _progressAnimation.value,
                          phase: currentPhase,
                          strokeWidth: 8, // Increased stroke width
                          backgroundColor: const Color(0xFF072E33),
                          progressColor: const Color(0xFF2CACAD),
                        ),
                      ),

                      // Pulsing Effect
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 260, // Increased from 240
                              height: 260, // Increased from 240
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF05161A).withOpacity(0.3),
                              ),
                            ),
                          );
                        },
                      ),

                      // Center Content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Phase Label
                          Text(
                            currentPhase,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF75E2E0),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Time Display with seconds
                          Text(
                            _formatTimeWithSeconds(timeInPhaseSeconds),
                            style: const TextStyle(
                              fontSize: 52, // Increased from 48
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD9F5F0),
                              fontFamily: 'monospace',
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Sessions Completed
                          Text(
                            '${_getCompletedSessions(roomDetails)} of ${roomDetails.totalSessions ?? 4} sessions',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6DA5C0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Status Message
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF072E33).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Timer synchronized across all users',
                    style: TextStyle(
                      color: Color(0xFF75E2E0),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 32), // Increased spacing
                // Debug Info - Moved down and styled
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05161A).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2CACAD).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Elapsed: $elapsedMinutes minutes',
                        style: const TextStyle(
                          color: Color(0xFF6DA5C0),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Phase: $currentPhase',
                        style: const TextStyle(
                          color: Color(0xFF6DA5C0),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time in Phase: ${_formatTimeWithSeconds(timeInPhaseSeconds)}',
                        style: const TextStyle(
                          color: Color(0xFF6DA5C0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: Text(
            'Loading room data...',
            style: TextStyle(color: Color(0xFFD9F5F0)),
          ),
        );
      },
    );
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:00';
    }
    return '${mins.toString().padLeft(2, '0')}:00';
  }

  String _formatTimeWithSeconds(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int _getCompletedSessions(dynamic roomDetails) {
    if (roomDetails.createdAt == null) return 0;

    final now = DateTime.now();
    final createdAt = roomDetails.createdAt.toDate();
    final elapsed = now.difference(createdAt);
    final elapsedMinutes = elapsed.inMinutes;

    final workDuration = roomDetails.workDuration ?? 25;
    final breakDuration = roomDetails.breakDuration ?? 5;
    final fullCycle = workDuration + breakDuration;

    return (elapsedMinutes ~/ fullCycle)
        .clamp(0, roomDetails.totalSessions ?? 4)
        .toInt();
  }
}

class CircularTimerPainter extends CustomPainter {
  final double progress;
  final String phase;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CircularTimerPainter({
    required this.progress,
    required this.phase,
    this.strokeWidth = 8,
    this.backgroundColor = const Color(0xFF05161A),
    this.progressColor = const Color(0xFF2CACAD),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Background circle
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    // Draw progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -1.5708, // Start from top (-π/2)
      2 * 3.14159 * progress, // Progress * 2π
      false,
      progressPaint,
    );

    // Inner circle border
    final innerBorderPaint =
        Paint()
          ..color = const Color(0xFF0C7075).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 20, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
