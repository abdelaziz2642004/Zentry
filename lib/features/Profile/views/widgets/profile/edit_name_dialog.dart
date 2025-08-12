import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_states.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_states.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';

class EditNameDialog extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSuccess;

  const EditNameDialog({
    super.key,
    required this.controller,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileStates>(
      listener: (context, state) async {
        if (state is FullNameSuccessState) {
          Navigator.pop(context); // Close the dialog on success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Full name updated successfully!')),
          );
          onSuccess(
            Provider.of<UserProvider>(context, listen: false).user!.fullName,
          );
        } else if (state is FullNameErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        if (state is AccountLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        return AlertDialog(
          title: const Text('Edit Full Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new full name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Provider.of<UserProvider>(context, listen: false)
                      .user!
                      .fullName = newName;
                  await BlocProvider.of<ProfileCubit>(
                    context,
                  ).changeFullName(newName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
