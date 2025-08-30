import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/app_initializer.dart';
import 'package:zentry_pomodoro_app/core/providers/app_providers.dart';
import 'package:zentry_pomodoro_app/core/splash/splash_manager.dart';
import 'package:zentry_pomodoro_app/core/app_lifecycle_manager.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppProviders(
      child: AppLifecycleManager(
        child: MaterialApp(
          title: 'Zentry Pomodoro App',
          home: Scaffold(body: SplashManager()),
        ),
      ),
    );
  }
}
