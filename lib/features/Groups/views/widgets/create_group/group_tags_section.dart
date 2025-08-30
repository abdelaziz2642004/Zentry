import 'package:flutter/material.dart';

class GroupTagsSection extends StatefulWidget {
  final List<String> tags;
  final Function(String) onAddTag;
  final Function(String) onRemoveTag;

  const GroupTagsSection({
    super.key,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  State<GroupTagsSection> createState() => _GroupTagsSectionState();
}

class _GroupTagsSectionState extends State<GroupTagsSection> {
  final TextEditingController _tagsController = TextEditingController();

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty) {
      widget.onAddTag(tag);
      _tagsController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _tagsController,
          decoration: InputDecoration(
            labelText: 'Tags (comma separated)',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTag,
            ),
          ),
          onFieldSubmitted: (_) => _addTag(),
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                widget.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => widget.onRemoveTag(tag),
                      ),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }
}
