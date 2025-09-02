import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Home/views/screens/create_room_bottom_sheet.dart';

import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/custom_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/custom_drawer.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/recently_joined.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/quick_stats_section.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/rooms_grid_builder.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/daily_time_tracker.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';

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



  @override
  Widget build(BuildContext context) {
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
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: _buildRecentlyJoinedSection(),
                      ),
                    ),

                    // Quick stats with animated cards
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildAnimatedQuickStats(),
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
