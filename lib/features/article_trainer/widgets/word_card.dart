import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../models/vocabulary_word.dart';
import '../../../providers/audio_provider.dart';

/// Displays the current German noun to classify.
/// Shows the word prominently with its English translation
/// and example sentence as hints.
class WordCard extends ConsumerWidget {
  final VocabularyWord word;

  const WordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.cardDarkGradient
            : const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF5F3FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? AppColors.primaryIndigo.withValues(alpha: 0.3)
              : AppColors.primaryIndigo.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryIndigo.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Question prompt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Der, Die, oder Das?',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.primaryIndigo,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          32.verticalSpace,

          // The German word with audio button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word.germanWord,
                style: context.textTheme.displayLarge?.copyWith(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              8.horizontalSpace,
              IconButton(
                onPressed: () => ref.read(audioServiceProvider).speak(word.germanWord),
                icon: const Icon(Icons.volume_up_rounded, size: 28),
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                tooltip: 'Listen',
              ),
            ],
          ),

          16.verticalSpace,

          // English translation (smaller hint)
          Text(
            word.englishTranslation,
            style: context.textTheme.titleMedium?.copyWith(
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),

          24.verticalSpace,

          // Example sentence (additional context)
          if (word.exampleSentence.isNotEmpty)
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
                      Icon(
                        Icons.format_quote_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary,
                      ),
                      8.horizontalSpace,
                      Text(
                        'Beispiel',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  8.verticalSpace,
                  Text(
                    word.exampleSentence,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Plural form hint (if available)
          if (word.pluralForm.isNotEmpty) ...[
            12.verticalSpace,
            Text(
              'Plural: ${word.pluralForm}',
              style: context.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textDarkSecondary
                    : AppColors.textLightSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
