import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_progress.dart';

/// Provider for the user's gamification progress.
///
/// In Phase 1, this uses mock data. Later phases will persist via Hive.
final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>(
  (ref) => UserProgressNotifier(),
);

class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier()
      : super(
          UserProgress(
            currentStreak: 7,
            longestStreak: 14,
            totalXp: 1250,
            todayXp: 65,
            level: 3,
            wordsLearned: 48,
            wordsMastered: 22,
            lessonsCompleted: 15,
            lastActivityDate: DateTime.now(),
            themeProgress: {
              'Begrüßung & Vorstellung': 0.85,
              'Familie & Freunde': 0.60,
              'Essen & Trinken': 0.35,
              'At the Mensa': 0.20,
              'City Transit': 0.10,
              'Sustainable Resources Engineering': 0.05,
            },
          ),
        );

  /// Add XP and update streak.
  void addXp(int amount) {
    final now = DateTime.now();
    final wasActiveToday = state.isActiveToday;

    int newStreak = state.currentStreak;
    if (!wasActiveToday) {
      // Check if yesterday was the last activity
      final yesterday = now.subtract(const Duration(days: 1));
      if (state.lastActivityDate != null &&
          state.lastActivityDate!.year == yesterday.year &&
          state.lastActivityDate!.month == yesterday.month &&
          state.lastActivityDate!.day == yesterday.day) {
        newStreak += 1;
      } else if (!wasActiveToday) {
        newStreak = 1; // Reset streak
      }
    }

    state = state.copyWith(
      totalXp: state.totalXp + amount,
      todayXp: wasActiveToday ? state.todayXp + amount : amount,
      currentStreak: newStreak,
      longestStreak:
          newStreak > state.longestStreak ? newStreak : state.longestStreak,
      lastActivityDate: now,
    );
  }

  /// Mark a lesson as completed.
  void completeLesson(String lessonId, int xpReward) {
    if (!state.completedLessonIds.contains(lessonId)) {
      state = state.copyWith(
        completedLessonIds: [...state.completedLessonIds, lessonId],
        lessonsCompleted: state.lessonsCompleted + 1,
      );
      addXp(xpReward);
    }
  }

  /// Increment words learned count.
  void learnWord() {
    state = state.copyWith(wordsLearned: state.wordsLearned + 1);
  }

  /// Increment words mastered count.
  void masterWord() {
    state = state.copyWith(wordsMastered: state.wordsMastered + 1);
  }
}
