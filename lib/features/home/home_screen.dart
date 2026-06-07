import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_progress_provider.dart';
import 'widgets/streak_card.dart';
import 'widgets/xp_progress_bar.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/daily_goal_ring.dart';

/// The main Home Dashboard screen — the user's hub for
/// streaks, XP, daily goals, and quick access to lessons.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Text(
                    '⚡',
                    style: const TextStyle(fontSize: 28),
                  ),
                  8.horizontalSpace,
                  Text(
                    'DeutschBlitz',
                    style: context.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              actions: [
                // Theme toggle button
                IconButton(
                  key: const Key('theme_toggle'),
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      key: ValueKey(isDark),
                      color: isDark
                          ? AppColors.xpGold
                          : AppColors.primaryIndigo,
                    ),
                  ),
                ),
                // Profile avatar
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryIndigo.withOpacity(0.2),
                    child: Text(
                      'S',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Body Content ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting
                  _GreetingSection(progress: progress)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),

                  20.verticalSpace,

                  // Streak + Daily Goal row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: const StreakCard()
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 100.ms)
                            .slideX(begin: -0.1, end: 0),
                      ),
                      16.horizontalSpace,
                      Expanded(
                        flex: 2,
                        child: const DailyGoalRing()
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 200.ms)
                            .slideX(begin: 0.1, end: 0),
                      ),
                    ],
                  ),

                  20.verticalSpace,

                  // XP Progress Bar
                  const XpProgressBar()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                  24.verticalSpace,

                  // Start Lesson CTA
                  _StartLessonButton()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.15, end: 0)
                      .then()
                      .shimmer(
                        duration: 1800.ms,
                        color: Colors.white.withOpacity(0.1),
                      ),

                  24.verticalSpace,

                  // Quick Actions Header
                  Text(
                    'Quick Practice',
                    style: context.textTheme.headlineMedium,
                  ).animate()
                      .fadeIn(duration: 500.ms, delay: 500.ms),

                  16.verticalSpace,

                  // Quick Action Grid
                  const QuickActionGrid()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 600.ms)
                      .slideY(begin: 0.1, end: 0),

                  24.verticalSpace,

                  // Stats summary
                  _StatsRow(progress: progress)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 700.ms)
                      .slideY(begin: 0.1, end: 0),

                  32.verticalSpace,
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Greeting section with dynamic time-based message.
class _GreetingSection extends StatelessWidget {
  final dynamic progress;

  const _GreetingSection({required this.progress});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Guten Morgen! ☀️';
    if (hour < 17) return 'Guten Tag! 🌤️';
    return 'Guten Abend! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        4.verticalSpace,
        Text(
          'Level ${progress.level} · ${progress.wordsLearned} words learned',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.isDarkMode
                ? AppColors.textDarkSecondary
                : AppColors.textLightSecondary,
          ),
        ),
      ],
    );
  }
}

/// Primary CTA button to start a lesson.
class _StartLessonButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryIndigo.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.go('/article-trainer');
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                12.horizontalSpace,
                Text(
                  'Start Lesson',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact stats row showing key metrics.
class _StatsRow extends StatelessWidget {
  final dynamic progress;

  const _StatsRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark
        ? AppColors.surfaceDarkCard
        : AppColors.surfaceLightCard;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    return Row(
      children: [
        _StatTile(
          label: 'Mastered',
          value: '${progress.wordsMastered}',
          icon: Icons.star_rounded,
          iconColor: AppColors.xpGold,
          cardColor: cardColor,
          borderColor: borderColor,
        ),
        12.horizontalSpace,
        _StatTile(
          label: 'Lessons',
          value: '${progress.lessonsCompleted}',
          icon: Icons.menu_book_rounded,
          iconColor: AppColors.secondaryTeal,
          cardColor: cardColor,
          borderColor: borderColor,
        ),
        12.horizontalSpace,
        _StatTile(
          label: 'Best Streak',
          value: '${progress.longestStreak}',
          icon: Icons.emoji_events_rounded,
          iconColor: AppColors.streakOrange,
          cardColor: cardColor,
          borderColor: borderColor,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color cardColor;
  final Color borderColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            8.verticalSpace,
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            4.verticalSpace,
            Text(
              label,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
