import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_states.dart';
import 'package:zentry_pomodoro_app/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';

import 'editable_name_row.dart';
import 'edit_name_dialog.dart';
import 'profile_email.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  String fullName = '';

  @override
  void initState() {
    super.initState();
    // Removed Provider.of<UserProvider>(context) from here
  }

  void _editFullName() {
    final TextEditingController controller = TextEditingController(
      text: fullName,
    );
    final lastcubit = BlocProvider.of<ProfileCubit>(context);
    showDialog(
      context: context,
      builder:
          (context) => BlocProvider.value(
            value: lastcubit,
            child: EditNameDialog(
              controller: controller,
              onSuccess: (newName) {
                setState(() {
                  fullName = newName;
                });
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FullNameErrorState) {
          return Center(
            child: Text(
              '${AppConstants.errorLoadingFullName}${state.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        final FireUser currentUser =
            Provider.of<UserProvider>(context).user ?? FireUser();
        if (fullName.isEmpty && currentUser.fullName.isNotEmpty) {
          fullName = currentUser.fullName;
        }
        return Column(
          children: [
            if (currentUser.fullName != 'Guest')
              EditableNameRow(fullName: fullName, onEdit: _editFullName),
            ProfileEmail(email: currentUser.email),
          ],
        );
      },
    );
  }
}
