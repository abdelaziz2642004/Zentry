import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/guest_mode_cubit.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friends_list_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/friend_requests_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/blocked_users_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/discovery_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/my_groups_cubit.dart';
import 'package:zentry_pomodoro_app/features/Groups/viewmodels/group_chat_cubit.dart';
import 'package:zentry_pomodoro_app/features/Friends/viewmodels/chat_cubit.dart';
import 'package:zentry_pomodoro_app/core/get_it.dart';

/// Centralizes all app-level state management with Bloc pattern
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider pattern providers
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),

        // Bloc pattern providers
        // BlocProvider<UserCubit>(create: (_) => UserCubit()),
        BlocProvider<GuestmodeCubit>(create: (_) => GuestmodeCubit()),

        // Global cubits - available throughout the app
        BlocProvider<RoomCubit>(create: (_) => getIt<RoomCubit>()),
        BlocProvider<FriendsCubit>(create: (_) => FriendsCubit()),
        BlocProvider<FriendsListCubit>(create: (_) => FriendsListCubit()),
        BlocProvider<FriendRequestsCubit>(create: (_) => FriendRequestsCubit()),
        BlocProvider<BlockedUsersCubit>(create: (_) => BlockedUsersCubit()),
        BlocProvider<GroupsCubit>(create: (_) => GroupsCubit()),
        BlocProvider<DiscoveryGroupsCubit>(
          create: (_) => DiscoveryGroupsCubit(),
        ),
        BlocProvider<MyGroupsCubit>(create: (_) => MyGroupsCubit()),
        BlocProvider<GroupChatCubit>(create: (_) => GroupChatCubit()),
        BlocProvider<ChatCubit>(create: (_) => ChatCubit()),
      ],
      child: child,
    );
  }
}
