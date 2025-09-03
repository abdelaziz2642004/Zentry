import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_cubit.dart';
import 'package:zentry_pomodoro_app/features/Profile/viewmodels/account_states.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/features/Authentication/views/screens/login_screen.dart';
import 'package:zentry_pomodoro_app/features/Profile/views/screens/change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountStates>(
      listener: (context, state) {
        if (state is UserDeletionSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Loginscreen()),
            (route) => false,
          );
        } else if (state is UserDeletionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: const Color(0xFF2CACAD),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF05161A),
        body: Stack(
          children: [
            // Animated background with particles
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.2 *
                            math.sin(_backgroundController.value * 2 * math.pi),
                        0.2 *
                            math.cos(_backgroundController.value * 2 * math.pi),
                      ),
                      radius:
                          1.3 +
                          (0.3 *
                              math.sin(
                                _backgroundController.value * 3 * math.pi,
                              )),
                      colors: [
                        const Color(0xFF0C7075).withOpacity(0.25),
                        const Color(0xFF072E33).withOpacity(0.15),
                        const Color(0xFF05161A),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Floating particles
                      ...List.generate(6, (index) {
                        final particleOffset =
                            (_backgroundController.value + index * 0.16) % 1.0;
                        return Positioned(
                          left:
                              60 +
                              (index * 50) +
                              (25 * math.sin(particleOffset * 2 * math.pi)),
                          top:
                              120 +
                              (index * 100) +
                              (20 * math.cos(particleOffset * 2.2 * math.pi)),
                          child: Opacity(
                            opacity:
                                0.08 +
                                (0.04 * math.sin(particleOffset * 3 * math.pi)),
                            child: Container(
                              width:
                                  1.5 +
                                  (0.5 *
                                      math.sin(particleOffset * 5 * math.pi)),
                              height:
                                  1.5 +
                                  (0.5 *
                                      math.sin(particleOffset * 5 * math.pi)),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2CACAD),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2CACAD,
                                    ).withOpacity(0.2),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),

            // Main content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Modern App Bar
                  SliverAppBar(
                    expandedHeight: 100,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: const Color(0xFFD9F5F0),
                              size: 24,
                              shadows: [
                                Shadow(
                                  color: const Color(
                                    0xFF2CACAD,
                                  ).withOpacity(0.3),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF05161A).withOpacity(0.95),
                            const Color(0xFF072E33).withOpacity(0.9),
                            const Color(0xFF0C7075).withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2CACAD).withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FlexibleSpaceBar(
                        centerTitle: true,
                        title: AnimatedBuilder(
                          animation: _contentController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                15 * (1 - _contentController.value),
                              ),
                              child: Opacity(
                                opacity: _contentController.value,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      duration: const Duration(seconds: 2),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, iconValue, child) {
                                        return Transform.scale(
                                          scale:
                                              1.0 +
                                              (0.08 *
                                                  math.sin(
                                                    iconValue * 3 * math.pi,
                                                  )),
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                colors: [
                                                  const Color(
                                                    0xFF2CACAD,
                                                  ).withOpacity(0.25),
                                                  const Color(
                                                    0xFF0F9E9C,
                                                  ).withOpacity(0.12),
                                                  Colors.transparent,
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF2CACAD,
                                                  ).withOpacity(0.15),
                                                  blurRadius: 5,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.settings_rounded,
                                              color: const Color(0xFF2CACAD),
                                              size: 18,
                                              shadows: [
                                                Shadow(
                                                  color: const Color(
                                                    0xFF2CACAD,
                                                  ).withOpacity(0.4),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ShaderMask(
                                      shaderCallback:
                                          (bounds) => LinearGradient(
                                            colors: [
                                              const Color(0xFFD9F5F0),
                                              const Color(0xFF2CACAD),
                                              const Color(0xFFD9F5F0),
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        'Settings',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.4,
                                          shadows: [
                                            Shadow(
                                              color: Color(0xFF05161A),
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
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
                      ),
                    ),
                  ),

                  // Settings Content
                  SliverToBoxAdapter(
                    child: BlocBuilder<AccountCubit, AccountStates>(
                      builder: (context, state) {
                        if (state is AccountLoadingState) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(
                                            0xFF2CACAD,
                                          ).withOpacity(0.2),
                                          Colors.transparent,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFF2CACAD),
                                      ),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Processing...',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFD9F5F0,
                                      ).withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return AnimatedBuilder(
                          animation: _contentController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                30 * (1 - _contentController.value),
                              ),
                              child: Opacity(
                                opacity: _contentController.value,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      // Account Security Section
                                      if (FirebaseAuth.instance.currentUser !=
                                          null) ...[
                                        _buildSectionCard(
                                          title: '🔐 Account Security',
                                          children: [
                                            _buildSettingsTile(
                                              icon: Icons.key,
                                              title: 'Change Password',
                                              subtitle:
                                                  'Update your account password',
                                              onTap: () {
                                                final accountCubit =
                                                    BlocProvider.of<
                                                      AccountCubit
                                                    >(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          _,
                                                        ) => BlocProvider.value(
                                                          value: accountCubit,
                                                          child:
                                                              const ChangePasswordScreen(),
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            _buildDangerSettingsTile(
                                              icon: Icons.delete,
                                              title: 'Delete Account',
                                              subtitle:
                                                  'Permanently remove your account',
                                              onTap:
                                                  () =>
                                                      _showDeleteAccountDialog(
                                                        context,
                                                      ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),
                                      ],

                                      // App Preferences Section
                                      _buildSectionCard(
                                        title: '⚙️ App Preferences',
                                        children: [
                                          _buildSwitchTile(
                                            icon: Icons.notifications,
                                            title: 'Notifications',
                                            subtitle:
                                                'Receive study reminders and updates',
                                            value: _notificationsEnabled,
                                            onChanged: (value) {
                                              setState(() {
                                                _notificationsEnabled = value;
                                              });
                                            },
                                          ),
                                          _buildSwitchTile(
                                            icon: Icons.volume_up,
                                            title: 'Sound Effects',
                                            subtitle:
                                                'Play sounds for timer events',
                                            value: _soundEnabled,
                                            onChanged: (value) {
                                              setState(() {
                                                _soundEnabled = value;
                                              });
                                            },
                                          ),
                                          _buildSwitchTile(
                                            icon: Icons.vibration,
                                            title: 'Vibration',
                                            subtitle:
                                                'Vibrate on timer completion',
                                            value: _vibrationEnabled,
                                            onChanged: (value) {
                                              setState(() {
                                                _vibrationEnabled = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // Study Settings Section
                                      _buildSectionCard(
                                        title: '📚 Study Settings',
                                        children: [
                                          _buildSettingsTile(
                                            icon: Icons.timer,
                                            title: 'Default Timer',
                                            subtitle:
                                                '25 minutes work, 5 minutes break',
                                            trailing: Icon(
                                              Icons.chevron_right,
                                              color: const Color(0xFF2CACAD),
                                              size: 20,
                                            ),
                                            onTap: () {
                                              // TODO: Navigate to timer settings
                                            },
                                          ),
                                          _buildSettingsTile(
                                            icon: Icons.center_focus_strong,
                                            title: 'Focus Mode',
                                            subtitle:
                                                'Block distracting apps during study',
                                            trailing: Icon(
                                              Icons.chevron_right,
                                              color: const Color(0xFF2CACAD),
                                              size: 20,
                                            ),
                                            onTap: () {
                                              // TODO: Navigate to focus mode settings
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // About Section
                                      _buildSectionCard(
                                        title: 'ℹ️ About',
                                        children: [
                                          _buildSettingsTile(
                                            icon: Icons.info,
                                            title: 'App Version',
                                            subtitle: '1.0.0 (Latest)',
                                            onTap: () {},
                                          ),
                                          _buildSettingsTile(
                                            icon: Icons.privacy_tip,
                                            title: 'Privacy Policy',
                                            subtitle:
                                                'Learn how we protect your data',
                                            trailing: Icon(
                                              Icons.open_in_new,
                                              color: const Color(0xFF2CACAD),
                                              size: 18,
                                            ),
                                            onTap: () {
                                              // TODO: Open privacy policy
                                            },
                                          ),
                                          _buildSettingsTile(
                                            icon: Icons.article,
                                            title: 'Terms of Service',
                                            subtitle:
                                                'Read our terms and conditions',
                                            trailing: Icon(
                                              Icons.open_in_new,
                                              color: const Color(0xFF2CACAD),
                                              size: 18,
                                            ),
                                            onTap: () {
                                              // TODO: Open terms of service
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 40,
                                      ), // Bottom padding
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF05161A).withOpacity(0.8),
                  const Color(0xFF072E33).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2CACAD).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD9F5F0),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                ...children,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2CACAD).withOpacity(0.2),
                      const Color(0xFF0F9E9C).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CACAD).withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: const Color(0xFF2CACAD), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD9F5F0),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFD9F5F0).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.2),
                      Colors.red.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFD9F5F0).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2CACAD).withOpacity(0.2),
                  const Color(0xFF0F9E9C).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.1),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF2CACAD), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD9F5F0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFD9F5F0).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF2CACAD),
              inactiveTrackColor: const Color(0xFF072E33),
              inactiveThumbColor: const Color(0xFFD9F5F0).withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: AlertDialog(
                  backgroundColor: const Color(0xFF072E33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.warning_rounded, color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          color: const Color(0xFFD9F5F0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'This action cannot be undone. All your data, progress, and achievements will be permanently deleted.',
                    style: TextStyle(
                      color: const Color(0xFFD9F5F0).withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD9F5F0),
                      ),
                      child: const Text('Cancel'),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.red.shade700],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          BlocProvider.of<AccountCubit>(
                            context,
                          ).deleteAccount();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete Forever'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
