import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:zentry_pomodoro_app/features/Authentication/viewmodels/guest_mode_cubit.dart';
import 'package:zentry_pomodoro_app/core/providers/user_provider.dart';

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
        // Room cubits are provided at screen level for better lifecycle management
      ],
      child: child,
    );
  }
}
