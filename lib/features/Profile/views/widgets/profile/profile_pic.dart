import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/widgets/Sign%20Up/image_picker.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_states.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key, required this.onUploadStateChanged});
  final void Function(bool) onUploadStateChanged;

  @override
  State createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileErrorState) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        }
        return Stack(
          children: [
            UserImagePicker(
              onPickImage: (image) async {
                widget.onUploadStateChanged(true); // disable navigation
                final profileCubit = BlocProvider.of<ProfileCubit>(context);
                await profileCubit.changeImage(image);
                // After successful upload, update UserProvider if state is success
                final state = profileCubit.state;
                if (state is ProfileImageSuccessState) {
                  final userProvider = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );
                  final user = userProvider.user;
                  if (user != null) {
                    user.imageUrl = state.imageUrl;
                    userProvider.setUser(user); // notifies listeners
                  }
                }
                widget.onUploadStateChanged(false); // enable navigation
              },
              fromProfile: true,
            ),
          ],
        );
      },
    );
  }
}
