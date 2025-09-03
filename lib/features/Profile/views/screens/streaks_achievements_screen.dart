import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zentry_pomodoro_app/core/colors.dart';
import 'package:zentry_pomodoro_app/core/constants/fonts.dart';

class StreaksAndAchievementsScreen extends StatefulWidget {
  const StreaksAndAchievementsScreen({super.key});

  @override
  State<StreaksAndAchievementsScreen> createState() =>
      _StreaksAndAchievementsScreenState();
}

class _StreaksAndAchievementsScreenState
    extends State<StreaksAndAchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 18),
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
    return Scaffold(
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
                      0.25 *
                          math.sin(_backgroundController.value * 2 * math.pi),
                      0.25 *
                          math.cos(_backgroundController.value * 2 * math.pi),
                    ),
                    radius:
                        1.4 +
                        (0.4 *
                            math.sin(
                              _backgroundController.value * 3 * math.pi,
                            )),
                    colors: [
                      const Color(0xFF0C7075).withOpacity(0.28),
                      const Color(0xFF072E33).withOpacity(0.18),
                      const Color(0xFF05161A),
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Floating particles
                    ...List.generate(7, (index) {
                      final particleOffset =
                          (_backgroundController.value + index * 0.14) % 1.0;
                      return Positioned(
                        left:
                            70 +
                            (index * 45) +
                            (28 * math.sin(particleOffset * 2 * math.pi)),
                        top:
                            140 +
                            (index * 90) +
                            (22 * math.cos(particleOffset * 2.3 * math.pi)),
                        child: Opacity(
                          opacity:
                              0.09 +
                              (0.05 * math.sin(particleOffset * 3.5 * math.pi)),
                          child: Container(
                            width:
                                1.8 +
                                (0.7 * math.sin(particleOffset * 5 * math.pi)),
                            height:
                                1.8 +
                                (0.7 * math.sin(particleOffset * 5 * math.pi)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2CACAD),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2CACAD,
                                  ).withOpacity(0.25),
                                  blurRadius: 4,
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
                  expandedHeight: 110,
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
                                color: const Color(0xFF2CACAD).withOpacity(0.3),
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
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
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
                              18 * (1 - _contentController.value),
                            ),
                            child: Opacity(
                              opacity: _contentController.value,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(seconds: 3),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, iconValue, child) {
                                      return Transform.scale(
                                        scale:
                                            1.0 +
                                            (0.1 *
                                                math.sin(
                                                  iconValue * 4 * math.pi,
                                                )),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            gradient: RadialGradient(
                                              colors: [
                                                const Color(
                                                  0xFF2CACAD,
                                                ).withOpacity(0.3),
                                                const Color(
                                                  0xFF0F9E9C,
                                                ).withOpacity(0.15),
                                                Colors.transparent,
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF2CACAD,
                                                ).withOpacity(0.2),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.emoji_events,
                                            color: const Color(0xFF2CACAD),
                                            size: 20,
                                            shadows: [
                                              Shadow(
                                                color: const Color(
                                                  0xFF2CACAD,
                                                ).withOpacity(0.5),
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
                                      'Streaks & Achievements',
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

                // Content
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _contentController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 40 * (1 - _contentController.value)),
                        child: Opacity(
                          opacity: _contentController.value,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                // Hero Stats Card
                                _buildHeroStatsCard(),

                                const SizedBox(height: 24),

                                // Current Streaks Grid
                                _buildStreaksGrid(),

                                const SizedBox(height: 24),

                                // Achievements Gallery
                                _buildAchievementsGallery(),

                                const SizedBox(height: 40), // Bottom padding
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatsCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0C7075).withOpacity(0.4),
                  const Color(0xFF072E33).withOpacity(0.7),
                  const Color(0xFF05161A).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF2CACAD).withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2CACAD).withOpacity(0.2),
                  blurRadius: 25,
                  spreadRadius: 3,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: const Color(0xFF0F9E9C).withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 5,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                // Hero Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.withOpacity(0.3),
                            Colors.orange.withOpacity(0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [
                              const Color(0xFFD9F5F0),
                              const Color(0xFF2CACAD),
                              Colors.amber,
                            ],
                          ).createShader(bounds),
                      child: Text(
                        'Your Progress Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildHeroStat(
                        icon: Icons.local_fire_department,
                        iconColor: Colors.orange,
                        value: '5',
                        label: 'Day Streak',
                        isMain: true,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildHeroStat(
                        icon: Icons.timer,
                        iconColor: const Color(0xFF2CACAD),
                        value: '2h',
                        label: 'Focus Time',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: const Color(0xFF2CACAD).withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildHeroStat(
                        icon: Icons.trending_up,
                        iconColor: Colors.green,
                        value: '85%',
                        label: 'Weekly',
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

  Widget _buildHeroStat({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    bool isMain = false,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMain ? 12 : 10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(isMain ? 16 : 12),
            border: Border.all(
              color: iconColor.withOpacity(0.3),
              width: isMain ? 2 : 1,
            ),
            boxShadow:
                isMain
                    ? [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                    : [],
          ),
          child: Icon(icon, color: iconColor, size: isMain ? 28 : 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isMain ? 24 : 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFD9F5F0),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFD9F5F0).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStreaksGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '🔥 Active Streaks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD9F5F0),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStreakCard(
                icon: Icons.calendar_today,
                iconColor: const Color(0xFF2CACAD),
                title: 'Study Days',
                value: '12',
                subtitle: 'This month',
                delay: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStreakCard(
                icon: Icons.access_time,
                iconColor: Colors.purple,
                title: 'Total Hours',
                value: '47',
                subtitle: 'All time',
                delay: 200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStreakCard(
                icon: Icons.flash_on,
                iconColor: Colors.amber,
                title: 'Sessions',
                value: '89',
                subtitle: 'Completed',
                delay: 400,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStreakCard(
                icon: Icons.workspace_premium,
                iconColor: Colors.pink,
                title: 'Rank',
                value: '#3',
                subtitle: 'This week',
                delay: 600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withOpacity(0.1),
                    const Color(0xFF072E33).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD9F5F0),
                    ),
                  ),
                  const SizedBox(height: 4),
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
          ),
        );
      },
    );
  }

  Widget _buildAchievementsGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '🏆 Achievement Gallery',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD9F5F0),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildAchievementCard(
              icon: Icons.wb_sunny,
              title: 'Early Bird',
              subtitle: 'Morning sessions',
              isUnlocked: true,
              progress: 1.0,
              rarity: 'Common',
              delay: 0,
            ),
            _buildAchievementCard(
              icon: Icons.psychology,
              title: 'Focus Master',
              subtitle: 'No-break sessions',
              isUnlocked: false,
              progress: 0.7,
              rarity: 'Rare',
              delay: 200,
            ),
            _buildAchievementCard(
              icon: Icons.star,
              title: 'Consistency King',
              subtitle: '7-day streak',
              isUnlocked: false,
              progress: 0.5,
              rarity: 'Epic',
              delay: 400,
            ),
            _buildAchievementCard(
              icon: Icons.speed,
              title: 'Speed Demon',
              subtitle: '25 Pomodoros',
              isUnlocked: true,
              progress: 1.0,
              rarity: 'Common',
              delay: 600,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isUnlocked,
    required double progress,
    required String rarity,
    required int delay,
  }) {
    Color rarityColor =
        rarity == 'Epic'
            ? Colors.purple
            : rarity == 'Rare'
            ? Colors.blue
            : Colors.green;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 900 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isUnlocked
                        ? [
                          rarityColor.withOpacity(0.2),
                          const Color(0xFF072E33).withOpacity(0.8),
                        ]
                        : [
                          Colors.grey.withOpacity(0.1),
                          const Color(0xFF072E33).withOpacity(0.6),
                        ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isUnlocked
                        ? rarityColor.withOpacity(0.4)
                        : const Color(0xFF2CACAD).withOpacity(0.2),
                width: isUnlocked ? 2 : 1,
              ),
              boxShadow:
                  isUnlocked
                      ? [
                        BoxShadow(
                          color: rarityColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ]
                      : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Rarity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rarityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rarityColor.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      rarity,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: rarityColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient:
                          isUnlocked
                              ? RadialGradient(
                                colors: [
                                  Colors.amber.withOpacity(0.3),
                                  Colors.orange.withOpacity(0.1),
                                ],
                              )
                              : RadialGradient(
                                colors: [
                                  Colors.grey.withOpacity(0.2),
                                  Colors.grey.withOpacity(0.05),
                                ],
                              ),
                      shape: BoxShape.circle,
                      boxShadow:
                          isUnlocked
                              ? [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ]
                              : [],
                    ),
                    child: Icon(
                      icon,
                      color: isUnlocked ? Colors.amber : Colors.grey,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title & Subtitle
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color:
                          isUnlocked
                              ? const Color(0xFFD9F5F0)
                              : const Color(0xFFD9F5F0).withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFFD9F5F0).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Status or Progress
                  if (isUnlocked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Unlocked',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2CACAD),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF072E33),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2CACAD),
                                    const Color(0xFF0F9E9C),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
