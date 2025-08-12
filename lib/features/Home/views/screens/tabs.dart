// hello
import 'package:flutter/material.dart';

import 'package:zentry_pomodoro_app/features/Home/views/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Tabs/BottomNavBar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/core/get_it.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsState();
}

class _TabsState extends State<TabsScreen> {
  int _index = 0;

  void rebuild(int index) {
    setState(() {
      _index = index;
    });
  }

  Widget _buildScreenChooser(int index, void Function(int) rebuild) {
    switch (index) {
      case 0:
        return BlocProvider<RoomCubit>(
          create: (_) => getIt<RoomCubit>(),
          child: const Homescreen(),
        );
      default:
        return const Homescreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget buildScreen = _buildScreenChooser(_index, rebuild);

    return SafeArea(
      child: Scaffold(
        body: buildScreen,
        bottomNavigationBar: Bottomnavbar(index: _index, rebuild: rebuild),
      ),
    );
  }
}
