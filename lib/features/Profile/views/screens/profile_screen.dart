import 'dart:math' as math;
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
import 'package:zentry_pomodoro_app/features/Friends/views/widgets/friend_code/friend_code_display.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool isUploading = false;
  late AnimationController _backgroundController;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 16),
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
              SnackBar(
                content: const Text(
                  'Please wait until the upload finishes.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFF2CACAD),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.all(20),
              ),
            );
          }
        },
        canPop: !isUploading,
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
                              math.sin(
                                _backgroundController.value * 2 * math.pi,
                              ),
                          0.2 *
                              math.cos(
                                _backgroundController.value * 2 * math.pi,
                              ),
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
                              (_backgroundController.value + index * 0.16) %
                              1.0;
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
                                  (0.04 *
                                      math.sin(particleOffset * 3 * math.pi)),
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

              // Main content with SliverAppBar
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
                                                    ).withOpacity(0.4),
                                                    const Color(
                                                      0xFF75E2E0,
                                                    ).withOpacity(0.2),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF2CACAD,
                                                    ).withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.person_rounded,
                                                color: Color(0xFFD9F5F0),
                                                size: 20,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            colors: [
                                              const Color(0xFFD9F5F0),
                                              const Color(0xFF2CACAD),
                                              const Color(0xFF75E2E0),
                                            ],
                                            stops: [
                                              0.0,
                                              0.5 +
                                                  (0.3 *
                                                      math.sin(
                                                        _contentController
                                                                .value *
                                                            4 *
                                                            math.pi,
                                                      )),
                                              1.0,
                                            ],
                                          ).createShader(bounds);
                                        },
                                        child: const Text(
                                          'Profile',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
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

                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Profile card with clean design
                            _buildProfileCard(),

                            const SizedBox(height: 24),

                            // Friend code section
                            _buildFriendCodeSection(),

                            const SizedBox(height: 24),

                            // Options section
                            BlocProvider(
                              create:
                                  (context) => AccountCubit(AccountopsRepo()),
                              child: _buildOptionsSection(),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
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

  // Compact profile card with left-right layout
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF072E33).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2CACAD).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side - Compact profile picture and info
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Smaller profile picture
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2CACAD).withOpacity(0.8),
                          const Color(0xFF75E2E0).withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2CACAD).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: ProfilePicture(
                        onUploadStateChanged: setUploadingState,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Compact profile info with increased height constraints
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 105,
                        maxHeight: 125,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [ProfileInfo()],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right side - Compact achievements
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Compact achievement items
                  _buildCompactAchievement(
                    icon: Icons.local_fire_department_rounded,
                    value: '7',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 6),
                  _buildCompactAchievement(
                    icon: Icons.timer_rounded,
                    value: '245h',
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for compact achievement items
  Widget _buildCompactAchievement({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Simple friend code section
  Widget _buildFriendCodeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF072E33).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2CACAD).withOpacity(0.15),
          width: 1,
        ),
      ),
      child: const FriendCodeDisplay(),
    );
  }

  // Clean options section
  Widget _buildOptionsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF072E33).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2CACAD).withOpacity(0.15),
          width: 1,
        ),
      ),
      child: const ProfileOptions(),
    );
  }
}
