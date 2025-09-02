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
      backgroundColor: const Color(0xFF05161A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF2CACAD).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF05161A).withOpacity(0.9),
              const Color(0xFF072E33).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Study Group',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD9F5F0),
                ),
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
