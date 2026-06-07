import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../providers/audio_provider.dart';
import 'sentence_builder_provider.dart';

/// Sentence Builder screen — arrange words into correct German order.
class SentenceBuilderScreen extends ConsumerWidget {
  const SentenceBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(sentenceBuilderProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
        child: gameState.isFinished
            ? _ResultsView(gameState: gameState, ref: ref)
            : Column(
                children: [
                  _TopBar(gameState: gameState),
                  8.verticalSpace,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: gameState.progress,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                        valueColor: const AlwaysStoppedAnimation(AppColors.secondaryTeal),
                      ),
                    ),
                  ),
                  24.verticalSpace,
                  if (gameState.currentPuzzle != null) ...[
                    // English prompt
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.secondaryTeal.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Text('Translate to German:', style: context.textTheme.bodySmall?.copyWith(color: AppColors.secondaryTeal, fontWeight: FontWeight.w600)),
                            12.verticalSpace,
                            Text(gameState.currentPuzzle!.englishTranslation, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                            8.verticalSpace,
                            Text('💡 ${gameState.currentPuzzle!.hint}', style: context.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    24.verticalSpace,
                    // Placed words
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 80),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: gameState.showingResult
                                ? (gameState.lastWasCorrect == true ? AppColors.successGreen : AppColors.errorRed)
                                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
                            width: gameState.showingResult ? 2 : 1,
                          ),
                        ),
                        child: gameState.placedWords.isEmpty
                            ? Center(child: Text('Tap words below to build the sentence', style: context.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary)))
                            : Wrap(
                                spacing: 8, runSpacing: 8,
                                children: gameState.placedWords.map((word) => _WordChip(word: word, isPlaced: true, onTap: gameState.showingResult ? null : () => ref.read(sentenceBuilderProvider.notifier).removeWord(word))).toList(),
                              ),
                      ),
                    ),
                    if (gameState.showingResult) ...[
                      12.verticalSpace,
                      _ResultFeedback(isCorrect: gameState.lastWasCorrect == true, correctSentence: gameState.currentPuzzle!.germanSentence),
                    ],
                    24.verticalSpace,
                    if (!gameState.showingResult)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Wrap(
                          spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
                          children: gameState.availableWords.map((word) => _WordChip(word: word, isPlaced: false, onTap: () => ref.read(sentenceBuilderProvider.notifier).placeWord(word))).toList(),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SizedBox(
                        width: double.infinity, height: 56,
                        child: gameState.showingResult
                            ? ElevatedButton.icon(onPressed: () => ref.read(sentenceBuilderProvider.notifier).nextPuzzle(), icon: const Icon(Icons.arrow_forward_rounded), label: const Text('Next'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryIndigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))
                            : ElevatedButton.icon(
                                onPressed: gameState.availableWords.isEmpty ? () => ref.read(sentenceBuilderProvider.notifier).checkAnswer() : null,
                                icon: const Icon(Icons.check_rounded), label: const Text('Check'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryTeal, foregroundColor: Colors.white, disabledBackgroundColor: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightElevated, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final SentenceBuilderState gameState;
  const _TopBar({required this.gameState});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(onPressed: () => context.go('/'), icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)),
          const Spacer(),
          Text('🧩 Sätze bauen', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightElevated, borderRadius: BorderRadius.circular(20)),
            child: Text('${gameState.totalAnswered}/${gameState.puzzles.length}', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool isPlaced;
  final VoidCallback? onTap;
  const _WordChip({required this.word, required this.isPlaced, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isPlaced ? AppColors.primaryIndigo.withValues(alpha: 0.15) : (isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isPlaced ? AppColors.primaryIndigo.withValues(alpha: 0.4) : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1)), width: 1.5),
            boxShadow: isPlaced ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Text(word, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: isPlaced ? AppColors.primaryIndigo : null)),
        ),
      ),
    );
  }
}

class _ResultFeedback extends ConsumerWidget {
  final bool isCorrect;
  final String correctSentence;
  const _ResultFeedback({required this.isCorrect, required this.correctSentence});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCorrect ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isCorrect ? AppColors.successGreen.withValues(alpha: 0.3) : AppColors.errorRed.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: isCorrect ? AppColors.successGreen : AppColors.errorRed, size: 22),
              8.horizontalSpace,
              Text(isCorrect ? 'Richtig! 🎉' : 'Nicht ganz...', style: context.textTheme.titleMedium?.copyWith(color: isCorrect ? AppColors.successGreen : AppColors.errorRed, fontWeight: FontWeight.w700)),
            ]),
            8.verticalSpace, 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    isCorrect ? correctSentence : 'Correct: $correctSentence', 
                    style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), 
                    textAlign: TextAlign.center
                  )
                ),
                4.horizontalSpace,
                IconButton(
                  onPressed: () => ref.read(audioServiceProvider).speak(correctSentence),
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  color: context.isDarkMode ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}

class _ResultsView extends StatelessWidget {
  final SentenceBuilderState gameState;
  final WidgetRef ref;
  const _ResultsView({required this.gameState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (gameState.accuracy * 100).toInt();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(accuracyPct >= 70 ? '🏆' : '💪', style: const TextStyle(fontSize: 64)).animate().scale(begin: const Offset(0.0, 0.0), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.elasticOut),
            16.verticalSpace,
            Text(accuracyPct >= 70 ? 'Sehr gut!' : 'Weiter üben!', style: context.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
            24.verticalSpace,
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _StatChip(icon: Icons.check_circle_rounded, value: '${gameState.correctCount}', color: AppColors.successGreen),
              24.horizontalSpace,
              _StatChip(icon: Icons.cancel_rounded, value: '${gameState.incorrectCount}', color: AppColors.errorRed),
              24.horizontalSpace,
              _StatChip(icon: Icons.analytics_rounded, value: '$accuracyPct%', color: AppColors.secondaryTeal),
            ]),
            24.verticalSpace,
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
              child: Text('⚡ +${gameState.xpEarned} XP', style: context.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            32.verticalSpace,
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => context.go('/'), icon: const Icon(Icons.home_rounded), label: const Text('Home'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
              12.horizontalSpace,
              Expanded(flex: 2, child: ElevatedButton.icon(onPressed: () => ref.read(sentenceBuilderProvider.notifier).restart(), icon: const Icon(Icons.refresh_rounded), label: const Text('Play Again'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryIndigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 28),
      8.verticalSpace,
      Text(value, style: context.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w800)),
    ]);
  }
}
