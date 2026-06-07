import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../models/vocabulary_word.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../providers/audio_provider.dart';
import '../../core/constants/app_constants.dart';

/// Flashcard viewer for a specific theme deck.
class DeckDetailScreen extends ConsumerStatefulWidget {
  final String theme;

  const DeckDetailScreen({super.key, required this.theme});

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _masteredThisSession = 0;

  List<VocabularyWord> get _words =>
      ref.read(vocabularyProvider).where((w) => w.theme == widget.theme).toList();

  VocabularyWord get _currentWord => _words[_currentIndex];

  void _flip() => setState(() => _isFlipped = !_isFlipped);

  void _next() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _markMastered() {
    ref.read(vocabularyProvider.notifier).updateMastery(_currentWord.id, 1.0);
    ref.read(userProgressProvider.notifier).addXp(AppConstants.xpPerFlashcardMastered);
    setState(() => _masteredThisSession++);
    _next();
  }

  @override
  Widget build(BuildContext context) {
    final words = _words;
    final isDark = context.isDarkMode;

    if (words.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No words in this deck')),
      );
    }

    final word = words[_currentIndex];

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/vocabulary-decks'),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark
                          ? AppColors.textDarkPrimary
                          : AppColors.textLightPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDarkCard
                          : AppColors.surfaceLightElevated,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${words.length}',
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_masteredThisSession > 0) ...[
                    12.horizontalSpace,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.xpGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⭐ $_masteredThisSession',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: AppColors.xpGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Progress ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ((_currentIndex + 1) / words.length),
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primaryIndigo),
                ),
              ),
            ),

            16.verticalSpace,

            // ── Theme title ──
            Text(
              widget.theme,
              style: context.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
              ),
            ),

            // ── Flashcard ──
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < -100) _next();
                    if (details.primaryVelocity! > 100) _previous();
                  }
                },
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final rotate = Tween(begin: pi / 2, end: 0.0)
                          .animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ));
                      return AnimatedBuilder(
                        animation: rotate,
                        builder: (context, child) => Transform(
                          transform: Matrix4.rotationY(rotate.value),
                          alignment: Alignment.center,
                          child: child,
                        ),
                        child: child,
                      );
                    },
                    child: _isFlipped
                        ? _CardBack(
                            key: ValueKey('back-${word.id}'),
                            word: word,
                          )
                        : _CardFront(
                            key: ValueKey('front-${word.id}'),
                            word: word,
                          ),
                  ),
                ),
              ),
            ),

            // ── Tap hint ──
            Text(
              _isFlipped ? '← Swipe to navigate →' : 'Tap to flip',
              style: context.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
              ),
            ),

            16.verticalSpace,

            // ── Action Buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  // Previous
                  IconButton.filled(
                    onPressed: _currentIndex > 0 ? _previous : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.surfaceDarkCard
                          : AppColors.surfaceLightElevated,
                    ),
                  ),

                  const Spacer(),

                  // Mark mastered
                  ElevatedButton.icon(
                    onPressed: _markMastered,
                    icon: const Icon(Icons.star_rounded, size: 20),
                    label: const Text('Mastered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.xpGold,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Next
                  IconButton.filled(
                    onPressed:
                        _currentIndex < words.length - 1 ? _next : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.surfaceDarkCard
                          : AppColors.surfaceLightElevated,
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
}

/// Front of the flashcard — shows German word.
class _CardFront extends ConsumerWidget {
  final VocabularyWord word;

  const _CardFront({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.cardDarkGradient
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFF5F3FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primaryIndigo.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryIndigo.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Article badge
          if (word.article != Article.none)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _articleColor(word.article).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _articleColor(word.article).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                word.article.label.toUpperCase(),
                style: context.textTheme.labelMedium?.copyWith(
                  color: _articleColor(word.article),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          20.verticalSpace,

          // German word with audio button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word.germanWord,
                style: context.textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              8.horizontalSpace,
              IconButton(
                onPressed: () => ref.read(audioServiceProvider).speak(word.germanWord),
                icon: const Icon(Icons.volume_up_rounded, size: 32),
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                tooltip: 'Listen',
              ),
            ],
          ),

          if (word.pluralForm.isNotEmpty) ...[
            12.verticalSpace,
            Text(
              'Plural: ${word.pluralForm}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          24.verticalSpace,
          Icon(
            Icons.touch_app_rounded,
            color: isDark
                ? AppColors.textDarkSecondary.withValues(alpha: 0.4)
                : AppColors.textLightSecondary.withValues(alpha: 0.4),
            size: 28,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Color _articleColor(Article article) {
    switch (article) {
      case Article.der:
        return AppColors.derBlue;
      case Article.die:
        return AppColors.diePink;
      case Article.das:
        return AppColors.dasGreen;
      default:
        return AppColors.primaryIndigo;
    }
  }
}

/// Back of the flashcard — shows English translation + example.
class _CardBack extends ConsumerWidget {
  final VocabularyWord word;

  const _CardBack({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1A2040), Color(0xFF252560)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFF0F4FF), Color(0xFFE8EDFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.secondaryTeal.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryTeal.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Answer" label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'TRANSLATION',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.secondaryTeal,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          24.verticalSpace,

          // Full display word with article
          Text(
            word.displayWord,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          8.verticalSpace,

          // English
          Text(
            word.englishTranslation,
            style: context.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.secondaryTeal,
            ),
            textAlign: TextAlign.center,
          ),

          // Example
          if (word.exampleSentence.isNotEmpty) ...[
            24.verticalSpace,
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          word.exampleSentence,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(audioServiceProvider).speak(word.exampleSentence),
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  6.verticalSpace,
                  Text(
                    word.exampleTranslation,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
