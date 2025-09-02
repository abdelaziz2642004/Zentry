import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/utils/timezone_utils.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/leaderboard_service.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/data/services/daily_study_service.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile_popup_dialog.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  final DailyStudyService _dailyStudyService = DailyStudyService();

  Duration _currentUserStudyTime = Duration.zero;
  int _currentUserRank = 0;
  bool _isLoading = true;
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _todayDate = TimezoneUtils.getTodayDateString();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final currentUserStudyTime = await _dailyStudyService.getDailyStudyTime();
      final currentUserRank = await _leaderboardService.getCurrentUserRank();

      if (mounted) {
        setState(() {
          _currentUserStudyTime = currentUserStudyTime;
          _currentUserRank = currentUserRank;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Leaderboard'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentUserData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadCurrentUserData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Today's date header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: mainColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: mainColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Today, $_todayDate',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: mainColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Study Time Rankings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Current user's stats
                      if (_currentUserRank > 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: mainColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#$_currentUserRank',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your Rank Today',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      TimezoneUtils.formatDuration(
                                        _currentUserStudyTime,
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: mainColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Leaderboard title
                      Row(
                        children: [
                          Icon(Icons.leaderboard, color: mainColor),
                          const SizedBox(width: 8),
                          Text(
                            'Top Studiers Today',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Leaderboard list with StreamBuilder
                      StreamBuilder<List<LeaderboardEntry>>(
                        stream: _getLeaderboardStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading leaderboard',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _loadCurrentUserData,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 60,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final leaderboard = snapshot.data!;

                          if (leaderboard.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No study sessions today',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Be the first to start studying!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: leaderboard.length,
                            itemBuilder: (context, index) {
                              final entry = leaderboard[index];
                              final isCurrentUser =
                                  entry.userId ==
                                  FirebaseAuth.instance.currentUser?.uid;

                              return LeaderboardEntryWidget(
                                entry: entry,
                                isCurrentUser: isCurrentUser,
                                onTap:
                                    () => _showProfilePopup(
                                      context,
                                      entry.userId,
                                    ),
                                getRankColor: _getRankColor,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Stream<List<LeaderboardEntry>> _getLeaderboardStream() async* {
    while (true) {
      try {
        final leaderboard = await _leaderboardService.getTodayLeaderboard();
        yield leaderboard;
        // Update every 30 seconds
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        yield [];
        await Future.delayed(const Duration(seconds: 30));
      }
    }
  }

  void _showProfilePopup(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => ProfilePopupDialog(userId: userId),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.orange[700]!; // Bronze
      default:
        return mainColor;
    }
  }
}

/// Widget for individual leaderboard entry with real-time user data updates
class LeaderboardEntryWidget extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final VoidCallback onTap;
  final Color Function(int) getRankColor;

  const LeaderboardEntryWidget({
    super.key,
    required this.entry,
    required this.isCurrentUser,
    required this.onTap,
    required this.getRankColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? mainColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCurrentUser
                  ? mainColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: LeaderboardService().getUserDataStream(entry.userId),
          builder: (context, snapshot) {
            final userData = snapshot.data;
            final fullName =
                userData?[FirebaseConstants.fullNameField] ?? entry.fullName;
            final imageUrl =
                userData?[FirebaseConstants.imageUrlField] ?? entry.imageUrl;

            return ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Avatar
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      backgroundImage:
                          imageUrl != null && imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                      backgroundColor:
                          imageUrl != null && imageUrl.isNotEmpty
                              ? Colors.transparent
                              : Colors.grey[400],
                      onBackgroundImageError: (exception, stackTrace) {
                        // Handle image loading error silently
                      },
                      child:
                          imageUrl == null || imageUrl.isEmpty
                              ? Text(
                                fullName.isNotEmpty
                                    ? fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                              : null,
                    ),
                  ),
                  // Rank Badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: getRankColor(entry.rank),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '#${entry.rank}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      fullName,
                      style: TextStyle(
                        fontWeight:
                            isCurrentUser ? FontWeight.bold : FontWeight.w500,
                        color: isCurrentUser ? mainColor : Colors.black87,
                      ),
                    ),
                  ),
                  if (isCurrentUser)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'YOU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                'Tap to view profile',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    TimezoneUtils.formatDuration(entry.studyTime),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  Text(
                    'studied today',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
