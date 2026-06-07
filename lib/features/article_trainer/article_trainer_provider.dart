import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vocabulary_word.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../core/constants/app_constants.dart';

/// State for the Article Trainer mini-game.
class ArticleTrainerState {
  final List<VocabularyWord> words;
  final int currentIndex;
  final int correctCount;
  final int incorrectCount;
  final int streak;
  final int bestStreak;
  final Article? lastAnswer;
  final bool? lastWasCorrect;
  final bool isFinished;
  final DateTime startTime;

  const ArticleTrainerState({
    this.words = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.lastAnswer,
    this.lastWasCorrect,
    this.isFinished = false,
    required this.startTime,
  });

  VocabularyWord? get currentWord =>
      currentIndex < words.length ? words[currentIndex] : null;

  int get totalAnswered => correctCount + incorrectCount;
  int get totalWords => words.length;
  double get progress =>
      totalWords > 0 ? totalAnswered / totalWords : 0.0;
  double get accuracy =>
      totalAnswered > 0 ? correctCount / totalAnswered : 0.0;
  int get xpEarned => correctCount * AppConstants.xpPerArticleCorrect;

  Duration get elapsed => DateTime.now().difference(startTime);

  ArticleTrainerState copyWith({
    List<VocabularyWord>? words,
    int? currentIndex,
    int? correctCount,
    int? incorrectCount,
    int? streak,
    int? bestStreak,
    Article? lastAnswer,
    bool? lastWasCorrect,
    bool? isFinished,
  }) {
    return ArticleTrainerState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      lastWasCorrect: lastWasCorrect,
      isFinished: isFinished ?? this.isFinished,
      startTime: startTime,
    );
  }
}

/// Provider for the Article Trainer game state.
final articleTrainerProvider =
    StateNotifierProvider<ArticleTrainerNotifier, ArticleTrainerState>(
  (ref) => ArticleTrainerNotifier(ref),
);

class ArticleTrainerNotifier extends StateNotifier<ArticleTrainerState> {
  final Ref _ref;

  ArticleTrainerNotifier(this._ref)
      : super(ArticleTrainerState(startTime: DateTime.now())) {
    _initGame();
  }

  void _initGame() {
    final allWords = _ref.read(vocabularyProvider);
    // Filter to only words that have a real article (der/die/das)
    final withArticles = allWords
        .where((w) => w.article != Article.none)
        .toList();
    // Shuffle and take up to 15 words for one round
    withArticles.shuffle(Random());
    final roundWords = withArticles.take(15).toList();

    state = ArticleTrainerState(
      words: roundWords,
      startTime: DateTime.now(),
    );
  }

  /// User selects an article for the current word.
  void answer(Article selectedArticle) {
    final word = state.currentWord;
    if (word == null || state.isFinished) return;

    final isCorrect = word.article == selectedArticle;
    final newStreak = isCorrect ? state.streak + 1 : 0;
    final newBestStreak = newStreak > state.bestStreak
        ? newStreak
        : state.bestStreak;

    // Update mastery in vocabulary provider
    if (isCorrect) {
      final newMastery = (word.mastery + 0.15).clamp(0.0, 1.0);
      _ref.read(vocabularyProvider.notifier).updateMastery(word.id, newMastery);
    } else {
      final newMastery = (word.mastery - 0.05).clamp(0.0, 1.0);
      _ref.read(vocabularyProvider.notifier).updateMastery(word.id, newMastery);
    }

    final nextIndex = state.currentIndex + 1;
    final isDone = nextIndex >= state.words.length;

    state = state.copyWith(
      currentIndex: nextIndex,
      correctCount: isCorrect
          ? state.correctCount + 1
          : state.correctCount,
      incorrectCount: isCorrect
          ? state.incorrectCount
          : state.incorrectCount + 1,
      streak: newStreak,
      bestStreak: newBestStreak,
      lastAnswer: selectedArticle,
      lastWasCorrect: isCorrect,
      isFinished: isDone,
    );

    // Award XP when finished
    if (isDone) {
      _ref.read(userProgressProvider.notifier).addXp(state.xpEarned);
    }
  }

  /// Restart with a fresh shuffled set.
  void restart() {
    _initGame();
  }
}
