import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:zentry_pomodoro_app/core/constants/firebase_constants.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Room%20Grid%20Item/room_grid_item.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';

class RoomsGridBuilder extends StatefulWidget {
  const RoomsGridBuilder({super.key});

  @override
  State<RoomsGridBuilder> createState() => _RoomsGridBuilderState();
}

class _RoomsGridBuilderState extends State<RoomsGridBuilder> {
  Timer? _timer;
  List<PomodoroRoom> _activeRooms = [];

  @override
  void initState() {
    super.initState();
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
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance.ref(FirebaseConstants.roomsDbPath).onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text("No public rooms available."));
        }

        // Parse the data from Realtime Database
        final Map<dynamic, dynamic> roomsMap =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        // Convert the map to a list of PomodoroRoom objects
        final allRooms =
            roomsMap.entries
                .map((entry) => PomodoroRoom.fromRealtimeMap(entry.value))
                .toList();

        // Filter out finished rooms and private rooms
        _activeRooms =
            allRooms.where((room) {
              return !room.isFinished && room.isPublic;
            }).toList();

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
