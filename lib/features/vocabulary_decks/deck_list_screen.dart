import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../providers/vocabulary_provider.dart';
import '../../models/vocabulary_word.dart';

/// Grid screen showing all vocabulary theme decks.
class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allWords = ref.watch(vocabularyProvider);
    final isDark = context.isDarkMode;

    // Group words by theme
    final themes = <String, List<VocabularyWord>>{};
    for (final word in allWords) {
      themes.putIfAbsent(word.theme, () => []).add(word);
    }

    final themeEntries = themes.entries.toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
              leading: IconButton(
                onPressed: () => context.go('/'),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary,
                ),
              ),
              title: Text(
                '📚 Vokabeln',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            // ── Header ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a deck to study',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary,
                      ),
                    ),
                    12.verticalSpace,
                    // Stats row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.tealGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MiniStat(
                            value: '${allWords.length}',
                            label: 'Total Words',
                          ),
                          _MiniStat(
                            value: '${themeEntries.length}',
                            label: 'Decks',
                          ),
                          _MiniStat(
                            value:
                                '${allWords.where((w) => w.isMastered).length}',
                            label: 'Mastered',
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),

            // ── Deck Grid ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = themeEntries[index];
                    final theme = entry.key;
                    final words = entry.value;
                    final masteredCount =
                        words.where((w) => w.isMastered).length;
                    final progress = words.isEmpty
                        ? 0.0
                        : masteredCount / words.length;

                    return _DeckCard(
                      theme: theme,
                      wordCount: words.length,
                      masteredCount: masteredCount,
                      progress: progress,
                      colorIndex: index,
                      onTap: () => context.go(
                        '/vocabulary-decks/detail',
                        extra: theme,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (80 * index).ms,
                        )
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 400.ms,
                          delay: (80 * index).ms,
                        );
                  },
                  childCount: themeEntries.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        4.verticalSpace,
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

final _deckColors = [
  const [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
  const [Color(0xFF00BFA6), Color(0xFF00E5CC)],
  const [Color(0xFFFF7043), Color(0xFFFF5722)],
  const [Color(0xFF42A5F5), Color(0xFF1E88E5)],
  const [Color(0xFFEC407A), Color(0xFFD81B60)],
  const [Color(0xFFFFD54F), Color(0xFFFFC107)],
  const [Color(0xFF26A69A), Color(0xFF009688)],
];

final _deckEmojis = ['🇩🇪', '🍽️', '🏫', '🚋', '🏠', '🌿', '📖'];

class _DeckCard extends StatelessWidget {
  final String theme;
  final int wordCount;
  final int masteredCount;
  final double progress;
  final int colorIndex;
  final VoidCallback onTap;

  const _DeckCard({
    required this.theme,
    required this.wordCount,
    required this.masteredCount,
    required this.progress,
    required this.colorIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = _deckColors[colorIndex % _deckColors.length];
    final emoji = _deckEmojis[colorIndex % _deckEmojis.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDarkCard
                : AppColors.surfaceLightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors[0].withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const Spacer(),

              // Theme name
              Text(
                theme,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              4.verticalSpace,
              Text(
                '$wordCount words · $masteredCount mastered',
                style: context.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                  fontSize: 11,
                ),
              ),
              8.verticalSpace,

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation(colors[0]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
