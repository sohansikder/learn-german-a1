import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../article_trainer_provider.dart';

/// Full-screen overlay showing game results after all words are answered.
class ResultsOverlay extends StatelessWidget {
  final ArticleTrainerState gameState;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const ResultsOverlay({
    super.key,
    required this.gameState,
    required this.onRestart,
    required this.onBack,
  });

  String get _grade {
    final pct = gameState.accuracy;
    if (pct >= 0.9) return 'Ausgezeichnet! 🏆';
    if (pct >= 0.7) return 'Sehr gut! 🌟';
    if (pct >= 0.5) return 'Gut gemacht! 👍';
    return 'Weiter üben! 💪';
  }

  String get _emoji {
    final pct = gameState.accuracy;
    if (pct >= 0.9) return '🎉';
    if (pct >= 0.7) return '⭐';
    if (pct >= 0.5) return '👏';
    return '📚';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final accuracyPct = (gameState.accuracy * 100).toInt();

    return Container(
      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDarkElevated
                : AppColors.surfaceLightCard,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primaryIndigo.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryIndigo.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Big emoji
              Text(
                _emoji,
                style: const TextStyle(fontSize: 64),
              ).animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

              16.verticalSpace,

              // Grade text
              Text(
                _grade,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              24.verticalSpace,

              // Stats grid
              Row(
                children: [
                  _ResultStat(
                    label: 'Correct',
                    value: '${gameState.correctCount}',
                    color: AppColors.successGreen,
                    icon: Icons.check_circle_rounded,
                  ),
                  16.horizontalSpace,
                  _ResultStat(
                    label: 'Wrong',
                    value: '${gameState.incorrectCount}',
                    color: AppColors.errorRed,
                    icon: Icons.cancel_rounded,
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              16.verticalSpace,

              Row(
                children: [
                  _ResultStat(
                    label: 'Accuracy',
                    value: '$accuracyPct%',
                    color: AppColors.secondaryTeal,
                    icon: Icons.analytics_rounded,
                  ),
                  16.horizontalSpace,
                  _ResultStat(
                    label: 'Best Streak',
                    value: '${gameState.bestStreak}',
                    color: AppColors.streakOrange,
                    icon: Icons.local_fire_department_rounded,
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

              24.verticalSpace,

              // XP earned banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 20)),
                    8.horizontalSpace,
                    Text(
                      '+${gameState.xpEarned} XP earned',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              28.verticalSpace,

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Home'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onRestart,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            8.verticalSpace,
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            4.verticalSpace,
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
