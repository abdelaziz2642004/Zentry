import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/custom_button.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/custom_container.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/form_text_title.dart';

class WorkBreakDurationPicker extends StatefulWidget {
  final int duration;
  final int limit;
  final String text;
  final String dialogTitle;
  final Function(int) onDurationSelected;

  const WorkBreakDurationPicker({
    super.key,
    required this.duration,
    required this.limit,
    required this.dialogTitle,
    required this.text,
    required this.onDurationSelected,
  });

  @override
  State<WorkBreakDurationPicker> createState() =>
      _WorkBreakDurationPickerState();
}

class _WorkBreakDurationPickerState extends State<WorkBreakDurationPicker> {
  List<int> durations = [];
  late int selectedDuration;

  @override
  void initState() {
    super.initState();
    durations = List<int>.generate(widget.limit, (i) => i + 1);
    selectedDuration = widget.duration;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FormTextTitle(text: widget.text),
        CustomContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: lightSecondaryColor,
                        title: FormTextTitle(
                          text: widget.dialogTitle,
                          color: mainColor,
                          fontSize: 25,
                          shadow: light,
                        ),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                    initialItem: durations.indexOf(
                                      widget.duration,
                                    ),
                                  ),
                                  itemExtent: 35,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      selectedDuration = durations[index];
                                    });
                                  },
                                  children:
                                      durations
                                          .map(
                                            (min) =>
                                                Center(child: Text("$min")),
                                          )
                                          .toList(),
                                ),
                              ),
                              CustomButton(
                                bgColor: mainColor,
                                width: MediaQuery.of(context).size.width * 0.5,
                                onTap: () {
                                  widget.onDurationSelected(selectedDuration);
                                  Navigator.pop(context);
                                },
                                content: const Text(
                                  "Set",
                                  style: TextStyle(
                                    color: lightSecondaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.timelapse_outlined),
                  Text(
                    "${widget.duration} min",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
