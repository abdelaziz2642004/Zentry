import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/repositories/Profile_Repo.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/services/cloudinaryService.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/repositories/AccountOPS_Repo.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile/profile_info.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile/profile_options.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/widgets/profile/profile_pic.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isUploading = false;

  void setUploadingState(bool value) {
    setState(() {
      isUploading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => ProfileCubit(ProfileRepo(CloudinaryService())),
      child: PopScope(
        onPopInvokedWithResult: (can, T) {
          if (isUploading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please wait until the upload finishes.'),
              ),
            );
          }
        },
        canPop: isUploading == true ? false : true,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            appBar: AppBar(
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'DopisBold',
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfilePicture(onUploadStateChanged: setUploadingState),
                  const SizedBox(height: 16),
                  const ProfileInfo(),
                  const Divider(),
                  BlocProvider(
                    create: (context) => AccountCubit(AccountopsRepo()),
                    child: const ProfileOptions(),
                  ),
                  // Logout button removed - AuthCubit is now only available in LoginScreen
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
