import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/custom_container.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/Helping%20Widgets%20/form_text_title.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room%20/form_tag_item.dart';

class FormTags extends StatefulWidget {
  const FormTags({super.key, required this.tagsController});

  final List<TextEditingController> tagsController;

  @override
  State<FormTags> createState() => _FormTagsState();
}

class _FormTagsState extends State<FormTags> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          const FormTextTitle(text: "Tags"),
          SizedBox(
            height: 60,
            child: ListView.builder(
              itemCount: widget.tagsController.length + 1,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == widget.tagsController.length) {
                  if (widget.tagsController.length >= 5) return null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 5,
                    ),
                    child: CustomContainer(
                      hPadding: 12,
                      color: lightSecondaryColor,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.tagsController.add(TextEditingController());
                          });
                        },
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ),
                  );
                }
                return TagsFormItem(
                  tagController: widget.tagsController[index],
                  action: () {
                    setState(() {
                      widget.tagsController.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
