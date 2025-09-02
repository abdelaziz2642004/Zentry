import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/profile_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/repositories/Profile_Repo.dart';
import 'package:zentry_pomodoro_app/features/Profile/data/services/cloudinaryService.dart';
import 'package:zentry_pomodoro_app/features/Home/views/widgets/Home/profile_avatar.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_States.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/views/screens/room_screen.dart';
import 'package:zentry_pomodoro_app/core/functions.dart';
import 'package:zentry_pomodoro_app/core/SnackBars/FailedSnackBar.dart';

class Customappbar {
  static AppBar build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 90,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF02364A).withOpacity(0.95),
              const Color(0xFF024D60).withOpacity(0.9),
              const Color(0xFF0C7075).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF02364A).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
      title: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Text(
                'ZenTry',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: const Color(0xFFD9F5F0),
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        // Quick join button
        _buildActionButton(
          context: context,
          icon: Icons.qr_code_scanner,
          onPressed: () => _showJoinByCodeDialog(context),
          tooltip: 'Join by code',
          delay: 600,
        ),

        // Notifications button
        _buildNotificationButton(context),

        // Enhanced Profile Avatar
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Container(
                margin: const EdgeInsets.only(left: 8, right: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2CACAD), Color(0xFF0F9E9C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFD9F5F0).withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BlocProvider(
                        create:
                            (_) =>
                                ProfileCubit(ProfileRepo(CloudinaryService())),
                        child: const ProfileAvatar(),
                      ),
                    ),
                    // Online status indicator
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F9E9C),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD9F5F0),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F9E9C).withOpacity(0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2CACAD).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2CACAD).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: const Color(0xFFD9F5F0), size: 20),
              tooltip: tooltip,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildNotificationButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2CACAD).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2CACAD).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () => _showNotificationsDialog(context),
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFFD9F5F0),
                    size: 20,
                  ),
                  tooltip: 'Notifications',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                // Notification badge
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F9E9C),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F9E9C).withOpacity(0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showJoinByCodeDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF05161A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF05161A), const Color(0xFF072E33)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2CACAD).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Color(0xFF2CACAD),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Join Room by Code',
                      style: TextStyle(
                        color: Color(0xFFD9F5F0),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the 6-digit room code:',
                  style: TextStyle(
                    color: const Color(0xFFD9F5F0).withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: Color(0xFFD9F5F0),
                    fontSize: 18,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '123456',
                    hintStyle: TextStyle(
                      color: const Color(0xFFD9F5F0).withOpacity(0.4),
                      letterSpacing: 2,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2CACAD).withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF2CACAD).withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF2CACAD).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2CACAD),
                        width: 2,
                      ),
                    ),
                    counterStyle: TextStyle(
                      color: const Color(0xFFD9F5F0).withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: const Color(0xFFD9F5F0).withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final code = codeController.text.trim();

                        if (!isValidRoomCode(code)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            failedSnackBar(
                              msg: 'Please enter a valid 6-digit code',
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pop();

                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFD9F5F0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('Joining room...'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF2CACAD),
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        try {
                          final roomCubit = BlocProvider.of<RoomCubit>(context);

                          if (roomCubit.state is RoomJoinLoadingState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              failedSnackBar(
                                msg: 'Already joining a room. Please wait.',
                              ),
                            );
                            return;
                          }

                          final navigator = Navigator.of(context);
                          await roomCubit.joinRoom(code);

                          if (context.mounted) {
                            navigator.push(
                              MaterialPageRoute(
                                builder:
                                    (_) => BlocProvider.value(
                                      value: roomCubit,
                                      child: RoomScreen(roomCode: code),
                                    ),
                              ),
                            );
                          }
                        } on Exception {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              failedSnackBar(
                                msg:
                                    'Room not found, has finished, or was deleted',
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2CACAD),
                        foregroundColor: const Color(0xFF05161A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Join',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF05161A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF2CACAD).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF05161A), const Color(0xFF072E33)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2CACAD).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Color(0xFF2CACAD),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Color(0xFFD9F5F0),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2CACAD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        color: const Color(0xFFD9F5F0).withOpacity(0.6),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No new notifications',
                        style: TextStyle(
                          color: const Color(0xFFD9F5F0).withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You\'re all caught up!',
                        style: TextStyle(
                          color: const Color(0xFFD9F5F0).withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CACAD),
                      foregroundColor: const Color(0xFF05161A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
