import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/repositories/chat_repository.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/repositories/room_repository.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/services/room_service.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_chat.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/joined_users_part.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/room_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/circular_timer_widget.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/room_info_card.dart';

class RoomScreen extends StatefulWidget {
  final String roomCode;

  const RoomScreen({super.key, required this.roomCode});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<RoomCubit>(context).joinRoom(widget.roomCode);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;

    return WillPopScope(
      onWillPop: () async {
        return await leaveroom(context, widget.roomCode);
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RoomChatCubit>(
            create: (context) => RoomChatCubit(ChatRepository()),
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFF02364A),
          appBar: RoomAppBar.build(widget.roomCode, context),
          body: SafeArea(
            child: Stack(
              children: [
                // Video background
                const VideoBackground(),

                // Main content
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Room Info Section
                      const RoomInfoCard(),

                      const SizedBox(height: 24),

                      // Circular Timer Section
                      const CircularTimerWidget(),

                      const SizedBox(height: 32),

                      // Joined Users Section (Full width)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Joineduserspart(roomCode: widget.roomCode),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Floating Chat Button
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingChatButton(
                    roomCode: widget.roomCode,
                    currentUser: currentUser,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Video background will be added here
class VideoBackground extends StatelessWidget {
  const VideoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Video background - simple and direct
          const VideoPlayerWidget(),

          // Dark overlay for better text readability
          Container(color: const Color(0xFF02364A).withOpacity(0.5)),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(
      'assets/videos/3695383-hd_1920_1080_30fps.mp4',
    );

    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: const Color(0xFF02364A),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF75E2E0)),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}

// Floating Chat Button Widget
class FloatingChatButton extends StatelessWidget {
  final String roomCode;
  final dynamic currentUser;

  const FloatingChatButton({
    super.key,
    required this.roomCode,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 56,
        minHeight: 56,
        maxWidth: 56,
        maxHeight: 56,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider<RoomChatCubit>(
                        create: (context) => RoomChatCubit(ChatRepository()),
                      ),
                      BlocProvider<RoomCubit>(
                        create:
                            (context) =>
                                RoomCubit(RoomRepository(RoomService())),
                      ),
                    ],
                    child: RoomChatScreen(
                      roomCode: roomCode,
                      currentUser: currentUser,
                    ),
                  ),
            ),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2CACAD), Color(0xFF0F9E9C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2CACAD).withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Room Chat Screen
class RoomChatScreen extends StatelessWidget {
  final String roomCode;
  final dynamic currentUser;

  const RoomChatScreen({
    super.key,
    required this.roomCode,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05161A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF072E33),
        foregroundColor: const Color(0xFFD9F5F0),
        title: const Row(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              color: const Color(0xFF75E2E0),
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Room Chat',
              style: const TextStyle(
                color: Color(0xFFD9F5F0),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF75E2E0)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF05161A).withOpacity(0.5),
        ),
        child:
            currentUser != null
                ? RoomChat(roomCode: roomCode, currentUser: currentUser)
                : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Color(0xFF0C7075),
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No user data available',
                        style: TextStyle(
                          color: Color(0xFFD9F5F0),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please log in to use chat',
                        style: TextStyle(
                          color: Color(0xFF6DA5C0),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
