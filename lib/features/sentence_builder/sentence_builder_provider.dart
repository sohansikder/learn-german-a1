import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_progress_provider.dart';
import '../../core/constants/app_constants.dart';

/// A sentence puzzle: user must arrange words in correct order.
class SentencePuzzle {
  final String id;
  final String germanSentence;
  final String englishTranslation;
  final String hint;
  final List<String> correctOrder;

  const SentencePuzzle({
    required this.id,
    required this.germanSentence,
    required this.englishTranslation,
    required this.hint,
    required this.correctOrder,
  });
}

class SentenceBuilderState {
  final List<SentencePuzzle> puzzles;
  final int currentIndex;
  final List<String> availableWords;
  final List<String> placedWords;
  final int correctCount;
  final int incorrectCount;
  final bool? lastWasCorrect;
  final bool isFinished;
  final bool showingResult;

  const SentenceBuilderState({
    this.puzzles = const [],
    this.currentIndex = 0,
    this.availableWords = const [],
    this.placedWords = const [],
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.lastWasCorrect,
    this.isFinished = false,
    this.showingResult = false,
  });

  SentencePuzzle? get currentPuzzle =>
      currentIndex < puzzles.length ? puzzles[currentIndex] : null;

  int get totalAnswered => correctCount + incorrectCount;
  double get progress =>
      puzzles.isNotEmpty ? totalAnswered / puzzles.length : 0.0;
  double get accuracy =>
      totalAnswered > 0 ? correctCount / totalAnswered : 0.0;
  int get xpEarned => correctCount * AppConstants.xpPerSentenceCorrect;

  SentenceBuilderState copyWith({
    List<SentencePuzzle>? puzzles,
    int? currentIndex,
    List<String>? availableWords,
    List<String>? placedWords,
    int? correctCount,
    int? incorrectCount,
    bool? lastWasCorrect,
    bool? isFinished,
    bool? showingResult,
  }) {
    return SentenceBuilderState(
      puzzles: puzzles ?? this.puzzles,
      currentIndex: currentIndex ?? this.currentIndex,
      availableWords: availableWords ?? this.availableWords,
      placedWords: placedWords ?? this.placedWords,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      lastWasCorrect: lastWasCorrect,
      isFinished: isFinished ?? this.isFinished,
      showingResult: showingResult ?? this.showingResult,
    );
  }
}

final sentenceBuilderProvider =
    StateNotifierProvider<SentenceBuilderNotifier, SentenceBuilderState>(
  (ref) => SentenceBuilderNotifier(ref),
);

class SentenceBuilderNotifier extends StateNotifier<SentenceBuilderState> {
  final Ref _ref;

  SentenceBuilderNotifier(this._ref)
      : super(const SentenceBuilderState()) {
    _initGame();
  }

  void _initGame() {
    final puzzles = List<SentencePuzzle>.from(_seedPuzzles)..shuffle(Random());
    final selected = puzzles.take(8).toList();

    state = SentenceBuilderState(puzzles: selected);
    _setupCurrentPuzzle();
  }

  void _setupCurrentPuzzle() {
    final puzzle = state.currentPuzzle;
    if (puzzle == null) return;

    final shuffled = List<String>.from(puzzle.correctOrder)..shuffle(Random());
    state = state.copyWith(
      availableWords: shuffled,
      placedWords: [],
    );
  }

  /// User taps a word from the available pool to add it to the sentence.
  void placeWord(String word) {
    if (!state.availableWords.contains(word)) return;

    final newAvailable = List<String>.from(state.availableWords)..remove(word);
    final newPlaced = [...state.placedWords, word];

    state = state.copyWith(
      availableWords: newAvailable,
      placedWords: newPlaced,
    );
  }

  /// User taps a placed word to remove it back to the pool.
  void removeWord(String word) {
    if (!state.placedWords.contains(word)) return;

    final newPlaced = List<String>.from(state.placedWords)..remove(word);
    final newAvailable = [...state.availableWords, word];

    state = state.copyWith(
      availableWords: newAvailable,
      placedWords: newPlaced,
    );
  }

  /// Check if the current arrangement is correct.
  void checkAnswer() {
    final puzzle = state.currentPuzzle;
    if (puzzle == null) return;

    final isCorrect =
        state.placedWords.join(' ') == puzzle.correctOrder.join(' ');

    state = state.copyWith(
      lastWasCorrect: isCorrect,
      correctCount:
          isCorrect ? state.correctCount + 1 : state.correctCount,
      incorrectCount:
          isCorrect ? state.incorrectCount : state.incorrectCount + 1,
      showingResult: true,
    );
  }

  /// Move to the next puzzle after showing result.
  void nextPuzzle() {
    final nextIndex = state.currentIndex + 1;
    final isDone = nextIndex >= state.puzzles.length;

    if (isDone) {
      _ref.read(userProgressProvider.notifier).addXp(state.xpEarned);
      state = state.copyWith(isFinished: true, showingResult: false);
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        showingResult: false,
      );
      _setupCurrentPuzzle();
    }
  }

  void restart() => _initGame();
}

/// Seed A1 sentence puzzles.
const _seedPuzzles = [
  SentencePuzzle(
    id: 's01',
    germanSentence: 'Ich trinke Kaffee.',
    englishTranslation: 'I drink coffee.',
    hint: 'Subject + Verb + Object',
    correctOrder: ['Ich', 'trinke', 'Kaffee.'],
  ),
  SentencePuzzle(
    id: 's02',
    germanSentence: 'Wir essen in der Mensa.',
    englishTranslation: 'We eat in the cafeteria.',
    hint: 'Subject + Verb + Preposition + Article + Noun',
    correctOrder: ['Wir', 'essen', 'in', 'der', 'Mensa.'],
  ),
  SentencePuzzle(
    id: 's03',
    germanSentence: 'Die Frau liest ein Buch.',
    englishTranslation: 'The woman reads a book.',
    hint: 'Article + Subject + Verb + Article + Object',
    correctOrder: ['Die', 'Frau', 'liest', 'ein', 'Buch.'],
  ),
  SentencePuzzle(
    id: 's04',
    germanSentence: 'Er geht zur Schule.',
    englishTranslation: 'He goes to school.',
    hint: 'Subject + Verb + Preposition + Noun',
    correctOrder: ['Er', 'geht', 'zur', 'Schule.'],
  ),
  SentencePuzzle(
    id: 's05',
    germanSentence: 'Das Kind spielt im Park.',
    englishTranslation: 'The child plays in the park.',
    hint: 'Article + Subject + Verb + Preposition + Noun',
    correctOrder: ['Das', 'Kind', 'spielt', 'im', 'Park.'],
  ),
  SentencePuzzle(
    id: 's06',
    germanSentence: 'Ich brauche einen Fahrschein.',
    englishTranslation: 'I need a ticket.',
    hint: 'Subject + Verb + Article + Object',
    correctOrder: ['Ich', 'brauche', 'einen', 'Fahrschein.'],
  ),
  SentencePuzzle(
    id: 's07',
    germanSentence: 'Der Kaffee ist heiß.',
    englishTranslation: 'The coffee is hot.',
    hint: 'Article + Subject + Verb + Adjective',
    correctOrder: ['Der', 'Kaffee', 'ist', 'heiß.'],
  ),
  SentencePuzzle(
    id: 's08',
    germanSentence: 'Mein Name ist Sohan.',
    englishTranslation: 'My name is Sohan.',
    hint: 'Possessive + Subject + Verb + Name',
    correctOrder: ['Mein', 'Name', 'ist', 'Sohan.'],
  ),
  SentencePuzzle(
    id: 's09',
    germanSentence: 'Die Wohnung ist groß.',
    englishTranslation: 'The apartment is big.',
    hint: 'Article + Subject + Verb + Adjective',
    correctOrder: ['Die', 'Wohnung', 'ist', 'groß.'],
  ),
  SentencePuzzle(
    id: 's10',
    germanSentence: 'Wir schützen die Umwelt.',
    englishTranslation: 'We protect the environment.',
    hint: 'Subject + Verb + Article + Object',
    correctOrder: ['Wir', 'schützen', 'die', 'Umwelt.'],
  ),
];
