import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/features/Friends/data/services/online_status_service.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  _AppLifecycleManagerState createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  final OnlineStatusService _onlineStatusService = OnlineStatusService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set user as online when app starts
    _setUserOnline();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle state changed: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        _setUserOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _setUserOffline();
        break;
      default:
        break;
    }
  }

  Future<void> _setUserOnline() async {
    try {
      await _onlineStatusService.setUserOnline();
      print('User set as online successfully');
    } catch (e) {
      print('Error setting user online: $e');
    }
  }

  Future<void> _setUserOffline() async {
    try {
      await _onlineStatusService.setUserOffline();
      print('User set as offline successfully');
    } catch (e) {
      print('Error setting user offline: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
