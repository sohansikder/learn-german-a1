import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';

/// A grid of quick-action cards for fast access to learning modules.
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'Der, Die, Das',
        subtitle: 'Article Trainer',
        emoji: '🎯',
        gradient: const LinearGradient(
          colors: [AppColors.derBlue, Color(0xFF1E88E5)],
        ),
        onTap: () => context.go('/article-trainer'),
      ),
      _QuickAction(
        title: 'Sätze bauen',
        subtitle: 'Sentence Builder',
        emoji: '🧩',
        gradient: const LinearGradient(
          colors: [AppColors.secondaryTeal, Color(0xFF00E5CC)],
        ),
        onTap: () => context.go('/sentence-builder'),
      ),
      _QuickAction(
        title: 'Vokabeln',
        subtitle: 'Flashcards',
        emoji: '🃏',
        gradient: AppColors.primaryGradient,
        onTap: () => context.go('/vocabulary-decks'),
      ),
      _QuickAction(
        title: 'Erfolge',
        subtitle: 'Achievements',
        emoji: '🏅',
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
        ),
        onTap: () => context.go('/achievements'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: actions.asMap().entries.map((entry) {
        return _QuickActionCard(action: entry.value)
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: (100 * entry.key).ms,
            )
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: 400.ms,
              delay: (100 * entry.key).ms,
            );
      }).toList(),
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final String emoji;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: action.gradient.colors.first.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: action.gradient.colors.first.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: action.gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    action.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.verticalSpace,
                  Text(
                    action.subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
