import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/SuccessSnackBar.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';

class RoomInfoCard extends StatefulWidget {
  const RoomInfoCard({super.key});

  @override
  State<RoomInfoCard> createState() => _RoomInfoCardState();
}

class _RoomInfoCardState extends State<RoomInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomStates>(
      buildWhen: (previous, current) {
        return current is RoomJoinSuccess || current is RoomUsersUpdated;
      },
      builder: (context, state) {
        if (state is RoomJoinSuccess || state is RoomUsersUpdated) {
          final roomDetails = (state as dynamic).room;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF05161A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2CACAD), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with toggle button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: const Color(0xFF072E33),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: const Color(0xFF75E2E0),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Room Details',
                        style: TextStyle(
                          color: Color(0xFFD9F5F0),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _toggleExpanded,
                        icon: AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: const Color(0xFF75E2E0),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expandable content
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isExpanded ? null : 0,
                  decoration: BoxDecoration(
                    color: _isExpanded ? null : const Color(0xFF05161A),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(_isExpanded ? 0 : 20),
                      bottomRight: Radius.circular(_isExpanded ? 0 : 20),
                    ),
                  ),
                  child:
                      _isExpanded
                          ? SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Room Code Section (Prominent)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2CACAD),
                                        Color(0xFF0F9E9C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2CACAD,
                                        ).withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.qr_code,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Room Code',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            roomDetails.roomCode ?? 'N/A',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'monospace',
                                              letterSpacing: 3,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            onPressed: () {
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text:
                                                      roomDetails.roomCode ??
                                                      '',
                                                ),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Room code copied!',
                                                  ),
                                                  backgroundColor: Color(
                                                    0xFF2CACAD,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.copy,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            tooltip: 'Copy room code',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Room Details Grid (2D Layout)
                                Container(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      // First Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoItem(
                                              Icons.timer,
                                              'Work Duration',
                                              '${roomDetails.workDuration ?? 25} min',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInfoItem(
                                              Icons.coffee,
                                              'Break Duration',
                                              '${roomDetails.breakDuration ?? 5} min',
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Second Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoItem(
                                              Icons.repeat,
                                              'Total Sessions',
                                              '${roomDetails.totalSessions ?? 4}',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInfoItem(
                                              Icons.people,
                                              'Capacity',
                                              '${roomDetails.capacity ?? 10}',
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Third Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoItem(
                                              Icons.room,
                                              'Room Name',
                                              roomDetails.name ??
                                                  'Study Session',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInfoItem(
                                              Icons.schedule,
                                              'Created',
                                              _formatTimeAgo(
                                                roomDetails.createdAt?.toDate(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Fourth Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoItem(
                                              Icons.public,
                                              'Visibility',
                                              roomDetails.isPublic == true
                                                  ? 'Public'
                                                  : 'Private',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInfoItem(
                                              Icons.people,
                                              'Joined Users',
                                              '${roomDetails.joinedUsers.length}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF072E33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2CACAD), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF75E2E0), size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6DA5C0),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD9F5F0),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
