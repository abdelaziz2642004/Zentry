// DONE
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/data/models/user.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_states.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/screens/profile_screen.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, profileState) {
        if (profileState is ProfileLoadingState) {
          // return const Center(child: CircularProgressIndicator());
        }

        if (profileState is ProfileErrorState) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        }

        if (profileState is ProfileImageSuccessState) {
          Provider.of<UserProvider>(context).user?.imageUrl =
              profileState.imageUrl;
        }

        final FireUser currentUser =
            Provider.of<UserProvider>(context).user ?? FireUser();

        return PopupMenuButton(
          itemBuilder:
              (context) => const [
                PopupMenuItem(value: 1, child: Text('Settings & Profile')),
              ],
          onSelected: (value) {
            if (value == 1) _openProfile(context);
          },
          child: CircleAvatar(
            radius: 20,
            backgroundImage:
                currentUser.imageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(currentUser.imageUrl)
                    : const AssetImage('assets/images/profile.jpg')
                        as ImageProvider,
          ),
        );
      },
    );
  }
}
