import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_cubit.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/viewmodels/study_tracking_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/repositories/Profile_Repo.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/services/cloudinaryService.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/profile_avatar.dart';

import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/views/screens/StudyCalendarScreen.dart';
import 'package:zentry_pomodoro_app/features/Study%20Time%20Tracking/views/screens/StudyStatsScreen.dart';

class Customappbar {
  static AppBar build(BuildContext context) {
    return AppBar(
      title: const Text(
        'ZenTry',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: mainColor,
      actions: [
        // Study Calendar Button
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudyCalendarScreen(),
              ),
            );
          },
          icon: const Icon(Icons.calendar_month),
          tooltip: 'Study Calendar',
        ),
        // Study Stats Button
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider<StudyTrackingCubit>(
                      create: (context) => StudyTrackingCubit(),
                      child: const StudyStatsScreen(),
                    ),
              ),
            );
          },
          icon: const Icon(Icons.analytics),
          tooltip: 'Study Statistics',
        ),
        BlocProvider(
          create: (_) => ProfileCubit(ProfileRepo(CloudinaryService())),
          child: const ProfileAvatar(),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
