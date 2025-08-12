import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/FailedSnackBar.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/SuccessSnackBar.dart';

import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/create_room_button_row.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/create_room_fields.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/create_room_schedule.dart';

import 'package:zentry_pomodoro_app/features/Room%20Operations/data/models/pomodoro_room.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';

class CreateRoomForm extends StatefulWidget {
  const CreateRoomForm({super.key});

  @override
  State<CreateRoomForm> createState() => _CreateRoomFormState();
}

class _CreateRoomFormState extends State<CreateRoomForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberOfSessionsController =
      TextEditingController(text: Dimensions.defaultSessions.toString());
  final List<TextEditingController> tagsController = [];
  final TextEditingController capacityController = TextEditingController(
    text: Dimensions.defaultCapacity.toString(),
  );
  bool isPrivate = false;

  int workDuration = Dimensions.defaultWorkDuration;
  int breakDuration = Dimensions.defaultBreakDuration;

  bool isScheduled = false;
  Timestamp scheduleTime = Timestamp.now();

  void _incrementCapacity() {
    final int current = int.tryParse(capacityController.text) ?? 0;
    if (current < Dimensions.maxRoomCapacity) {
      setState(() {
        capacityController.text = (current + 1).toString();
      });
    }
  }

  void _decrementCapacity() {
    final int current = int.tryParse(capacityController.text) ?? 0;
    if (current > Dimensions.minRoomCapacity) {
      setState(() {
        capacityController.text = (current - 1).toString();
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    numberOfSessionsController.dispose();
    capacityController.dispose();
    for (var controller in tagsController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomCubit, RoomStates>(
      listener: (context, state) {
        if (state is RoomCreationFailure) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(failedSnackBar());
        } else if (state is RoomCreationSuccess) {
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.of(context).pop(); // Close the bottom sheet

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            successSnackBar(msg: 'Room created successfully! Joining room...'),
          );

          // Automatically navigate to the room screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider.value(
                    value: BlocProvider.of<RoomCubit>(context),
                    child: RoomScreen(roomCode: state.roomCode),
                  ),
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CreateRoomFields(
              nameController: nameController,
              numberOfSessionsController: numberOfSessionsController,
              tagsController: tagsController,
              capacityController: capacityController,
              workDuration: workDuration,
              breakDuration: breakDuration,
              onWorkDurationChanged:
                  (value) => setState(() => workDuration = value),
              onBreakDurationChanged:
                  (value) => setState(() => breakDuration = value),
              incrementCapacity: _incrementCapacity,
              decrementCapacity: _decrementCapacity,
            ),
            CreateRoomSchedule(
              isScheduled: isScheduled,
              onScheduledChanged:
                  (value) => setState(() => isScheduled = value),
              onScheduleTimeSelected: (value) => scheduleTime = value,
            ),
            CreateRoomButtonRow(
              isPrivate: isPrivate,
              onTogglePrivate: () => setState(() => isPrivate = !isPrivate),
              onCreate: () {
                if (_formKey.currentState!.validate()) {
                  final room = PomodoroRoom(
                    creatorId: FirebaseAuth.instance.currentUser!.uid,
                    createdAt: Timestamp.fromDate(DateTime.now().toUtc()),
                    availableRoom: true,
                    name: nameController.text,
                    capacity: int.parse(capacityController.text),
                    workDuration: workDuration,
                    breakDuration: breakDuration,
                    isPublic: !isPrivate,
                    totalSessions: int.parse(numberOfSessionsController.text),
                    tags: tagsController.map((e) => e.text).toList(),
                    joinedUsers: [],
                    isScheduled: isScheduled,
                    scheduleTime: scheduleTime,
                  );
                  context.read<RoomCubit>().createRoom(room);
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    failedSnackBar(msg: AppConstants.fillAllFieldsMessage),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
