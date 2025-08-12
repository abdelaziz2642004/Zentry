import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/scheduler.dart';

class CreateRoomSchedule extends StatelessWidget {
  final bool isScheduled;
  final ValueChanged<bool> onScheduledChanged;
  final ValueChanged<dynamic> onScheduleTimeSelected;

  const CreateRoomSchedule({
    super.key,
    required this.isScheduled,
    required this.onScheduledChanged,
    required this.onScheduleTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ScheduleStartEndPicker(
      isScheduled: isScheduled,
      onScheduledChanged: onScheduledChanged,
      onScheduleTimeSelected: onScheduleTimeSelected,
    );
  }
}
