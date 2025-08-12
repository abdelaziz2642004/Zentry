import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/repositories/chat_repository.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_chat.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/joined_users_part.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/room_app_bar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/widgets/Room/room_details_timer.dart';

class RoomScreen extends StatefulWidget {
  final String roomCode;

  const RoomScreen({super.key, required this.roomCode});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    // final currentUser = BlocProvider.of<AuthCubit>(context).user;

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
          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(ChatRepository()),
          ),
        ],
        child: Scaffold(
          appBar: RoomAppBar.build(widget.roomCode, context),
          body: SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      labelColor: Colors.blue[600],
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: Colors.blue[600],
                      tabs: const [
                        Tab(icon: Icon(Icons.room), text: 'Room'),
                        Tab(
                          icon: Icon(Icons.chat_bubble_outline),
                          text: 'Chat',
                        ),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Room Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Room Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const RoomDetailsAndTimer(),

                              const SizedBox(height: 16),
                              const Text(
                                "Users in Room",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Joineduserspart(roomCode: widget.roomCode),
                            ],
                          ),
                        ),

                        // Chat Tab
                        currentUser != null
                            ? RoomChat(
                              roomCode: widget.roomCode,
                              currentUser: currentUser,
                            )
                            : const Center(
                              child: Text('Please log in to use chat'),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
