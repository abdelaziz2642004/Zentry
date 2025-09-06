import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zentry_pomodoro_app/core/get_it.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/room_grid_item.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/repositories/room_repository.dart';

class RoomsGridBuilder extends StatefulWidget {
  const RoomsGridBuilder({super.key});

  @override
  State<RoomsGridBuilder> createState() => _RoomsGridBuilderState();
}

class _RoomsGridBuilderState extends State<RoomsGridBuilder> {
  Timer? _timer;
  List<PomodoroRoom> _activeRooms = [];
  late final RoomRepository _roomRepository;

  @override
  void initState() {
    super.initState();
    _roomRepository = getIt<RoomRepository>();
    
    // Set up a timer to check every minute if any rooms are finished
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateActiveRooms();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateActiveRooms() {
    if (mounted) {
      setState(() {
        // Re-filter the rooms to remove any that have finished or are private
        _activeRooms =
            _activeRooms
                .where((room) => !room.isFinished && room.isPublic)
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PomodoroRoom>>(
      stream: _roomRepository.streamPublicRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No public rooms available."));
        }

        // Filter out finished rooms (additional safety check)
        _activeRooms = snapshot.data!
            .where((room) => !room.isFinished && room.isPublic)
            .toList();

        if (_activeRooms.isEmpty) {
          return const Center(child: Text("No active public rooms available."));
        }

        return MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _activeRooms.length,
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          itemBuilder:
              (context, index) => RoomGridItem(room: _activeRooms[index]),
        );
      },
    );
  }
}
