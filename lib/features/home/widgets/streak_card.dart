import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../providers/user_progress_provider.dart';

/// Displays the user's current daily streak with a flame animation effect.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.cardDarkGradient
            : const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.streakOrange.withOpacity(0.2)
              : AppColors.streakOrange.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakOrange.withOpacity(isDark ? 0.1 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Animated flame icon
              Text(
                '🔥',
                style: const TextStyle(fontSize: 28),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              )
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.15, 1.15),
                    duration: 800.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                  ),
              8.horizontalSpace,
              Text(
                'Daily Streak',
                style: context.textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${progress.currentStreak}',
                style: context.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 42,
                  color: AppColors.streakOrange,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  ' days',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ),
              ),
            ],
          ),
          8.verticalSpace,
          // Streak week dots
          _StreakWeekDots(currentStreak: progress.currentStreak),
        ],
      ),
    );
  }
}

/// Shows 7 dots representing the last week, filled based on streak.
class _StreakWeekDots extends StatelessWidget {
  final int currentStreak;

  const _StreakWeekDots({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final activeDays = currentStreak.clamp(0, 7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isActive = index < activeDays;
        return Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.streakOrange
                    : (isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08)),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.streakOrange.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isActive
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            4.verticalSpace,
            Text(
              labels[index],
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: isActive
                    ? AppColors.streakOrange
                    : (isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}
