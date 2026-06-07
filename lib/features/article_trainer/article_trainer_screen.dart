import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../models/vocabulary_word.dart';
import 'article_trainer_provider.dart';
import 'widgets/word_card.dart';
import 'widgets/article_buttons.dart';
import 'widgets/results_overlay.dart';

/// The Article Trainer mini-game screen.
/// Users sort nouns into Der (♂), Die (♀), Das (⚬) buckets.
class ArticleTrainerScreen extends ConsumerWidget {
  const ArticleTrainerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(articleTrainerProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Main game content
            Column(
              children: [
                // ── Top Bar ──
                _TopBar(gameState: gameState),
                16.verticalSpace,

                // ── Progress Bar ──
                _GameProgressBar(progress: gameState.progress),
                24.verticalSpace,

                // ── Streak indicator ──
                if (gameState.streak > 1)
                  _StreakBanner(streak: gameState.streak)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                // ── Word Card ──
                Expanded(
                  child: gameState.currentWord != null
                      ? _WordCardSection(
                          word: gameState.currentWord!,
                          lastWasCorrect: gameState.lastWasCorrect,
                          key: ValueKey(gameState.currentIndex),
                        )
                      : const SizedBox(),
                ),

                // ── Feedback flash ──
                if (gameState.lastWasCorrect != null)
                  _FeedbackFlash(
                    isCorrect: gameState.lastWasCorrect!,
                    correctArticle: gameState.currentIndex > 0
                        ? gameState.words[gameState.currentIndex - 1].article
                        : Article.der,
                  ).animate().fadeIn(duration: 200.ms).then().fadeOut(
                        delay: 800.ms,
                        duration: 300.ms,
                      ),

                // ── Article Buttons ──
                if (!gameState.isFinished)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: ArticleButtons(
                      onSelect: (article) {
                        ref
                            .read(articleTrainerProvider.notifier)
                            .answer(article);
                      },
                    ),
                  ),
              ],
            ),

            // Results overlay
            if (gameState.isFinished)
              ResultsOverlay(
                gameState: gameState,
                onRestart: () {
                  ref.read(articleTrainerProvider.notifier).restart();
                },
                onBack: () => context.go('/'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Top bar with back button, score, and timer.
class _TopBar extends StatelessWidget {
  final ArticleTrainerState gameState;

  const _TopBar({required this.gameState});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => context.go('/'),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textLightPrimary,
            ),
          ),

          const Spacer(),

          // Score badges
          _ScoreBadge(
            icon: Icons.check_circle_rounded,
            value: '${gameState.correctCount}',
            color: AppColors.successGreen,
          ),
          12.horizontalSpace,
          _ScoreBadge(
            icon: Icons.cancel_rounded,
            value: '${gameState.incorrectCount}',
            color: AppColors.errorRed,
          ),
          12.horizontalSpace,

          // Word counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDarkCard
                  : AppColors.surfaceLightElevated,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${gameState.totalAnswered}/${gameState.totalWords}',
              style: context.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _ScoreBadge({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        4.horizontalSpace,
        Text(
          value,
          style: context.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Animated progress bar for the game.
class _GameProgressBar extends StatelessWidget {
  final double progress;

  const _GameProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows current streak during the game.
class _StreakBanner extends StatelessWidget {
  final int streak;

  const _StreakBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.streakGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakOrange.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          6.horizontalSpace,
          Text(
            '$streak in a row!',
            style: context.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Central section showing the word card with entrance animation.
class _WordCardSection extends StatelessWidget {
  final VocabularyWord word;
  final bool? lastWasCorrect;

  const _WordCardSection({
    super.key,
    required this.word,
    this.lastWasCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WordCard(word: word)
          .animate()
          .fadeIn(duration: 350.ms)
          .slideX(begin: 0.15, end: 0, duration: 350.ms,
              curve: Curves.easeOutCubic)
          .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1.0, 1.0),
            duration: 350.ms,
          ),
    );
  }
}

/// Brief flash indicating correct/incorrect answer.
class _FeedbackFlash extends StatelessWidget {
  final bool isCorrect;
  final Article correctArticle;

  const _FeedbackFlash({
    required this.isCorrect,
    required this.correctArticle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.successGreen.withValues(alpha: 0.15)
            : AppColors.errorRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? AppColors.successGreen.withValues(alpha: 0.4)
              : AppColors.errorRed.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
            size: 20,
          ),
          8.horizontalSpace,
          Text(
            isCorrect
                ? 'Richtig! ✓'
                : 'It was "${correctArticle.label}"',
            style: context.textTheme.labelLarge?.copyWith(
              color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
