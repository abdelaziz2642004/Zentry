import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Create%20Room/Helping%20Widgets/custom_container.dart';

class TagsFormItem extends StatefulWidget {
  final TextEditingController tagController;
  final VoidCallback action;

  const TagsFormItem({
    super.key,
    required this.tagController,
    required this.action,
  });

  @override
  State<TagsFormItem> createState() => _TagsFormItemState();
}

class _TagsFormItemState extends State<TagsFormItem> {
  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 100),
          child: CustomContainer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.tagController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tag is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefix: Text('#'),
                      border: InputBorder.none,
                    ),
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          widget.action();
                        },
                        child: const Icon(Icons.remove, size: 12),
                      ),
                    ),
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
