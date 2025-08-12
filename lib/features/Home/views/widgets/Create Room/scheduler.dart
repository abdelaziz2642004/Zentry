import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/custom_container.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/form_text_title.dart';

class ScheduleStartEndPicker extends StatefulWidget {
  final bool isScheduled;
  final ValueChanged<bool> onScheduledChanged;
  final Function(Timestamp) onScheduleTimeSelected;

  const ScheduleStartEndPicker({
    super.key,
    required this.isScheduled,
    required this.onScheduledChanged,
    required this.onScheduleTimeSelected,
  });

  @override
  State<ScheduleStartEndPicker> createState() => _ScheduleStartEndPickerState();
}

class _ScheduleStartEndPickerState extends State<ScheduleStartEndPicker> {
  DateTime? scheduleTime;

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selected = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          scheduleTime = selected;
        });
        final Timestamp timestamp = Timestamp.fromDate(selected);
        widget.onScheduleTimeSelected(timestamp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const FormTextTitle(text: "Schedule"),
          value: widget.isScheduled,
          onChanged: widget.onScheduledChanged,
          activeColor: darkSecondaryColor,
          activeTrackColor: lightSecondaryColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FormTextTitle(
                text: "Starts On:",
                color: widget.isScheduled ? darkMainColor : grey,
                shadow: widget.isScheduled ? lightSecondaryColor : darkGrey,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    if (widget.isScheduled) {
                      _pickDateTime();
                    }
                  },
                  child: CustomContainer(
                    hPadding: 12,
                    vPadding: 10,
                    color: widget.isScheduled ? light : lightGrey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FormTextTitle(
                          text:
                              scheduleTime == null
                                  ? "Select date"
                                  : DateFormat(
                                    'dd/MM/yyyy @hh:mm a',
                                  ).format(scheduleTime!),

                          color: widget.isScheduled ? darkMainColor : grey,
                          fontWeight: FontWeight.w500,
                          shadow: widget.isScheduled ? light : darkGrey,
                        ),
                        Icon(
                          Icons.calendar_today_rounded,
                          color: widget.isScheduled ? darkMainColor : darkGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
