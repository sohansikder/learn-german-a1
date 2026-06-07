import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../providers/user_progress_provider.dart';

/// Circular progress ring showing daily XP goal completion.
class DailyGoalRing extends ConsumerWidget {
  const DailyGoalRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final isDark = context.isDarkMode;
    final goalPercent = progress.dailyGoalProgress;
    final isGoalMet = goalPercent >= 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDarkCard
            : AppColors.surfaceLightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 48,
            lineWidth: 8,
            percent: goalPercent,
            animation: true,
            animationDuration: 1200,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: isGoalMet
                ? AppColors.successGreen
                : AppColors.secondaryTeal,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isGoalMet ? '✅' : '${(goalPercent * 100).toInt()}%',
                  style: isGoalMet
                      ? const TextStyle(fontSize: 22)
                      : context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryTeal,
                        ),
                ),
              ],
            ),
          ),
          12.verticalSpace,
          Text(
            'Daily Goal',
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          4.verticalSpace,
          Text(
            '${progress.todayXp}/100 XP',
            style: context.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
