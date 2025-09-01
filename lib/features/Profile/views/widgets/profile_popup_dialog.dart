import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class ProfilePopupDialog extends StatelessWidget {
  final String userId;
  final String? userName;

  const ProfilePopupDialog({super.key, required this.userId, this.userName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(FirebaseConstants.usersCollection)
                .doc(userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (snapshot.hasError) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading profile',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_off, color: Colors.grey, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'User not found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final fullName =
              userData[FirebaseConstants.fullNameField] ?? 'Unknown';
          final username = userData[FirebaseConstants.usernameField] ?? '';
          final friendCode = userData[FirebaseConstants.friendCodeField] ?? '';
          final imageUrl = userData[FirebaseConstants.imageUrlField] ?? '';

          return Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: () {
                    if (imageUrl.isNotEmpty) {
                      _showFullScreenImage(context, imageUrl, fullName);
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: mainColor, width: 3),
                    ),
                    child: ClipOval(
                      child:
                          imageUrl.isNotEmpty
                              ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User Name
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Username
                if (username.isNotEmpty) ...[
                  Text(
                    '@$username',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // Friend Code Section
                if (friendCode.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              color: mainColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Friend Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  friendCode,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                    fontFamily: 'monospace',
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: friendCode),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Friend code copied to clipboard!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  color: mainColor,
                                  size: 20,
                                ),
                                tooltip: 'Copy friend code',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share this code with others to add them as friends',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Weekly Study Time Section
                const SizedBox(height: 16),
                _buildWeeklyStudyTimeSection(userId),
                const SizedBox(height: 16),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyStudyTimeSection(String userId) {
    // Get current week's dates (Saturday to Friday)
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday

    // Calculate Saturday of current week (weekday 6)
    final saturday = now.subtract(Duration(days: currentWeekday - 6));

    return FutureBuilder<Map<DateTime, Duration>>(
      future: _getWeeklyStudyData(userId, saturday),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Error loading study data',
            style: TextStyle(color: Colors.red),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final studyData = snapshot.data!;

        return Column(
          children: [
            // Days of the week
            Row(
              children:
                  ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((day) {
                    final isToday = _isToday(day, now);
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Colors.blue : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 4),

            // Study time bars
            Row(
              children: List.generate(7, (index) {
                final date = saturday.add(Duration(days: index));
                final studyTime = studyData[date] ?? Duration.zero;
                final isToday = _isToday(
                  ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'][index],
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
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isFuture
                                    ? Colors.grey[300]
                                    : studyTime.inMinutes > 0
                                    ? Colors.green[400]
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                            border:
                                isToday
                                    ? Border.all(color: Colors.blue, width: 2)
                                    : null,
                          ),
                          child: Center(
                            child: Text(
                              _formatStudyTime(studyTime),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color:
                                    isFuture || studyTime.inMinutes == 0
                                        ? Colors.grey[600]
                                        : Colors.white,
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
          ],
        );
      },
    );
  }

  Future<Map<DateTime, Duration>> _getWeeklyStudyData(
    String userId,
    DateTime saturday,
  ) async {
    final Map<DateTime, Duration> result = {};

    for (int i = 0; i < 7; i++) {
      final date = saturday.add(Duration(days: i));
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      try {
        final doc =
            await FirebaseFirestore.instance
                .collection(FirebaseConstants.dailyStatsCollection)
                .doc(userId)
                .collection('dates')
                .doc(dateString)
                .get();

        if (doc.exists) {
          final data = doc.data();
          final studyTimeSeconds =
              data?[FirebaseConstants.totalStudyTimeField] ?? 0;
          result[date] = Duration(seconds: studyTimeSeconds);
        } else {
          result[date] = Duration.zero;
        }
      } catch (e) {
        result[date] = Duration.zero;
      }
    }

    return result;
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

  Stream<Map<DateTime, Duration>> _getWeeklyStudyDataStream(String userId) {
    // This method is no longer used, keeping for compatibility
    return Stream.value({});
  }

  String _formatTotalTime(Duration duration) {
    // This method is no longer used, keeping for compatibility
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Full screen image
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.error,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Title
              Positioned(
                top: 40,
                left: 20,
                right: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
