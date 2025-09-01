import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/create_group/create_group_form.dart';
import 'package:zentry_pomodoro_app/features/Groups/views/widgets/create_group/create_group_actions.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();

  void _handleSubmit(
    String name,
    String description,
    String category,
    int maxMembers,
    List<String> tags,
    bool isPublic,
    String? password,
  ) {
    context.read<GroupsCubit>().createGroup(
      name: name,
      description: description,
      isPublic: isPublic,
      maxMembers: maxMembers,
      tags: tags,
      category: category,
      password: password,
    );
    Navigator.of(context).pop();
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Study Group',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CreateGroupForm(formKey: _formKey, onSubmit: _handleSubmit),
              const SizedBox(height: 20),
              CreateGroupActions(
                onCancel: _handleCancel,
                onSubmit: () {
                  if (_formKey.currentState!.validate()) {
                    // The form will handle the submission
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
