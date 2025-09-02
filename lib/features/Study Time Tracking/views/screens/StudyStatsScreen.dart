import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/viewmodels/study_tracking_cubit.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/viewmodels/study_tracking_states.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/views/screens/leaderboard_screen.dart';

class StudyStatsScreen extends StatefulWidget {
  const StudyStatsScreen({super.key});

  @override
  State<StudyStatsScreen> createState() => _StudyStatsScreenState();
}

class _StudyStatsScreenState extends State<StudyStatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudyTrackingCubit>().loadDailyStudyTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Statistics'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<StudyTrackingCubit, StudyTrackingStates>(
        builder: (context, state) {
          if (state is StudyTrackingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudyTrackingErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StudyTrackingCubit>().loadDailyStudyTime();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is StudyTrackingLoadedState) {
            return _buildStatsContent(context, state.dailyStudyTime);
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, Duration dailyStudyTime) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Study Time Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.today, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Today\'s Study Time',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TimezoneUtils.formatDuration(dailyStudyTime),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${TimezoneUtils.getTodayDateString()}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.timer, size: 48, color: Colors.blue[300]),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final cubit = context.read<StudyTrackingCubit>();
                            await cubit.getStudyTimeForLastDays(7);
                            // You could navigate to a detailed stats screen here
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('View History'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LeaderboardScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.leaderboard),
                          label: const Text('Leaderboard'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Reset Today\'s Time'),
                                    content: const Text(
                                      'Are you sure you want to reset today\'s study time? This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Reset'),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirmed == true) {
                              await context
                                  .read<StudyTrackingCubit>()
                                  .resetDailyStudyTime();
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Today'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Study Tips
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Study Tips',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStudyTip(
                    'Use the Pomodoro Technique',
                    'Work for 25 minutes, then take a 5-minute break.',
                    Icons.timer,
                  ),
                  const SizedBox(height: 8),
                  _buildStudyTip(
                    'Track Your Progress',
                    'Monitor your daily study time to stay motivated.',
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 8),
                  _buildStudyTip(
                    'Stay Consistent',
                    'Try to study at the same time each day.',
                    Icons.schedule,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTip(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
