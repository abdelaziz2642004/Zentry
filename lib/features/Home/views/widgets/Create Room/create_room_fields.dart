import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:zentry_pomodoro_app/core/constants/dimensions.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/form_text_title.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/capacity.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/form_tags.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/no_sessions.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/room_name.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/work_break_duration_picker.dart';

class CreateRoomFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController numberOfSessionsController;
  final List<TextEditingController> tagsController;
  final TextEditingController capacityController;
  final int workDuration;
  final int breakDuration;
  final ValueChanged<int> onWorkDurationChanged;
  final ValueChanged<int> onBreakDurationChanged;
  final VoidCallback incrementCapacity;
  final VoidCallback decrementCapacity;

  const CreateRoomFields({
    super.key,
    required this.nameController,
    required this.numberOfSessionsController,
    required this.tagsController,
    required this.capacityController,
    required this.workDuration,
    required this.breakDuration,
    required this.onWorkDurationChanged,
    required this.onBreakDurationChanged,
    required this.incrementCapacity,
    required this.decrementCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RoomName(nameController: nameController),
        const SizedBox(height: Dimensions.paddingMedium),
        NumberOfSessions(
          numberOfSessionsController: numberOfSessionsController,
        ),
        const SizedBox(height: Dimensions.spacingHuge),
        WorkBreakDurationPicker(
          duration: workDuration,
          limit: Dimensions.maxWorkDuration,
          dialogTitle: AppConstants.setWorkDuration,
          text: AppConstants.setWorkDuration,
          onDurationSelected: onWorkDurationChanged,
        ),
        const SizedBox(height: Dimensions.spacingHuge),
        WorkBreakDurationPicker(
          duration: breakDuration,
          limit: Dimensions.maxBreakDuration,
          dialogTitle: AppConstants.setBreakDuration,
          text: AppConstants.setBreakDuration,
          onDurationSelected: onBreakDurationChanged,
        ),
        const SizedBox(height: Dimensions.spacingHuge),
        const FormTextTitle(text: AppConstants.roomCapacity),
        Capacity(
          capacityController: capacityController,
          incrementCapacity: incrementCapacity,
          decrementCapacity: decrementCapacity,
        ),
        FormTags(tagsController: tagsController),
      ],
    );
  }
}
