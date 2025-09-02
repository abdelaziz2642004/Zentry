import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Home/views/screens/create_room_bottom_sheet.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/custom_button.dart';

import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/custom_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/custom_drawer.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/recently_joined.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/quick_stats_section.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/rooms_grid_builder.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/daily_time_tracker.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';

import 'package:zentry_pomodoro_app/core/functions.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/FailedSnackBar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfUserShouldJoin();
    });
  }

  Future<void> _checkIfUserShouldJoin() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      final roomCubit = BlocProvider.of<RoomCubit>(context);
      final navigator = Navigator.of(context);
      final roomCode = await roomCubit.atStart(user);

      if (roomCode != "" && mounted) {
        navigator.push(
          MaterialPageRoute(
            builder:
                (_) => BlocProvider<RoomCubit>.value(
                  value: roomCubit,
                  child: RoomScreen(roomCode: roomCode),
                ),
          ),
        );
      }
    }
  }

  void _showJoinByCodeDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Join Room by Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the 6-digit room code:'),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: '123456',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = codeController.text.trim();

                if (!isValidRoomCode(code)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    failedSnackBar(msg: 'Please enter a valid 6-digit code'),
                  );
                  return;
                }

                Navigator.of(context).pop();

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Joining room...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );

                try {
                  final roomCubit = BlocProvider.of<RoomCubit>(context);

                  // Check if already joining
                  if (roomCubit.state is RoomJoinLoadingState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      failedSnackBar(
                        msg: 'Already joining a room. Please wait.',
                      ),
                    );
                    return;
                  }

                  final navigator = Navigator.of(context);
                  await roomCubit.joinRoom(code);

                  // Navigate to room screen
                  if (context.mounted) {
                    navigator.push(
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider.value(
                              value: roomCubit,
                              child: RoomScreen(roomCode: code),
                            ),
                      ),
                    );
                  }
                } on Exception catch (e) {
                  e;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      failedSnackBar(
                        msg: 'Room not found, has finished, or was deleted',
                      ),
                    );
                  }
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomCubit = BlocProvider.of<RoomCubit>(context);
    return Scaffold(
      drawer: const Customdrawer(),
      appBar: Customappbar.build(context),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Video background
            const VideoBackground(),

            // Main content
            BlocBuilder<RoomCubit, RoomStates>(
              buildWhen: (previous, current) {
                return current is RoomLoadingState ||
                    current is RoomInitialState;
              },
              builder: (context, state) {
                if (state is RoomLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2CACAD)),
                  );
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Time tracker with glassmorphism
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: _buildGlassmorphicTimeTracker(),
                      ),
                    ),

                    // Recently joined section with parallax effect
                    SliverToBoxAdapter(child: _buildRecentlyJoinedSection()),

                    // Quick stats with animated cards
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildAnimatedQuickStats(),
                      ),
                    ),

                    // Public rooms section with compact header
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: _buildCompactPublicRoomsHeader(
                          context,
                          roomCubit,
                        ),
                      ),
                    ),

                    // Rooms grid with staggered animation
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: const RoomsGridBuilder(),
                      ),
                    ),

                    // Bottom spacing
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(),
    );
  }

  Widget _buildGlassmorphicTimeTracker() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF05161A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2CACAD).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2CACAD).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Timetrackertoday(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentlyJoinedSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: const Recentlyjoined(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedQuickStats() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 60 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F9E9C).withOpacity(0.1),
                    const Color(0xFF2CACAD).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0F9E9C).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const QuickStatsSection(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactPublicRoomsHeader(
    BuildContext context,
    RoomCubit roomCubit,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 70 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                // Simple icon and title
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2CACAD).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.public,
                    color: Color(0xFF2CACAD),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Title
                Expanded(
                  child: Text(
                    "Public Study Rooms",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD9F5F0),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Join by code button - compact design
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2CACAD), Color(0xFF0F9E9C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2CACAD).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showJoinByCodeDialog(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code,
                              color: Color(0xFFD9F5F0),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Join by Code",
                              style: TextStyle(
                                color: const Color(0xFFD9F5F0),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedFAB() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2CACAD), Color(0xFF0F9E9C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder:
                      (BuildContext ctx) => BlocProvider<RoomCubit>.value(
                        value: BlocProvider.of<RoomCubit>(context),
                        child: const CreateRoom(),
                      ),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: Color(0xFFD9F5F0), size: 28),
            ),
          ),
        );
      },
    );
  }
}
