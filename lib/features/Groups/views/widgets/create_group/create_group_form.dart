import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/create_group/group_basic_info_section.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/create_group/group_settings_section.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/create_group/group_tags_section.dart';

class CreateGroupForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(
    String name,
    String description,
    String category,
    int maxMembers,
    List<String> tags,
    bool isPublic,
    String? password,
  )
  onSubmit;

  const CreateGroupForm({
    super.key,
    required this.formKey,
    required this.onSubmit,
  });

  @override
  State<CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMembersController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedCategory = 'General';
  bool _isPublic = true;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _maxMembersController.text = '50';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (widget.formKey.currentState!.validate()) {
      widget.onSubmit(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        _selectedCategory,
        int.parse(_maxMembersController.text),
        _tags,
        _isPublic,
        !_isPublic ? _passwordController.text.trim() : null,
      );
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _updateCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _updatePrivacy(bool isPublic) {
    setState(() {
      _isPublic = isPublic;
      if (isPublic) {
        _passwordController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GroupBasicInfoSection(
            nameController: _nameController,
            descriptionController: _descriptionController,
            selectedCategory: _selectedCategory,
            onCategoryChanged: _updateCategory,
          ),
          const SizedBox(height: 16),
          GroupSettingsSection(
            maxMembersController: _maxMembersController,
            isPublic: _isPublic,
            passwordController: _passwordController,
            onPrivacyChanged: _updatePrivacy,
          ),
          const SizedBox(height: 16),
          GroupTagsSection(
            tags: _tags,
            onAddTag: _addTag,
            onRemoveTag: _removeTag,
          ),
        ],
      ),
    );
  }
}
