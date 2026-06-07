/// Tracks the user's gamification progress — streaks, XP, and level.
class UserProgress {
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final int todayXp;
  final int level;
  final int wordsLearned;
  final int wordsMastered;
  final int lessonsCompleted;
  final DateTime? lastActivityDate;
  final List<String> completedLessonIds;
  final Map<String, double> themeProgress; // theme → 0.0..1.0

  const UserProgress({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalXp = 0,
    this.todayXp = 0,
    this.level = 1,
    this.wordsLearned = 0,
    this.wordsMastered = 0,
    this.lessonsCompleted = 0,
    this.lastActivityDate,
    this.completedLessonIds = const [],
    this.themeProgress = const {},
  });

  /// XP required to reach the next level (simple quadratic curve).
  int get xpForNextLevel => level * 150;

  /// Progress towards next level as a fraction.
  double get levelProgress {
    final xpInCurrentLevel = totalXp - _cumulativeXpForLevel(level);
    return (xpInCurrentLevel / xpForNextLevel).clamp(0.0, 1.0);
  }

  int _cumulativeXpForLevel(int lvl) {
    int total = 0;
    for (int i = 1; i < lvl; i++) {
      total += i * 150;
    }
    return total;
  }

  /// Whether the user has been active today.
  bool get isActiveToday {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    return lastActivityDate!.year == now.year &&
        lastActivityDate!.month == now.month &&
        lastActivityDate!.day == now.day;
  }

  /// Daily XP goal completion percentage.
  double get dailyGoalProgress => (todayXp / 100).clamp(0.0, 1.0);

  UserProgress copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalXp,
    int? todayXp,
    int? level,
    int? wordsLearned,
    int? wordsMastered,
    int? lessonsCompleted,
    DateTime? lastActivityDate,
    List<String>? completedLessonIds,
    Map<String, double>? themeProgress,
  }) {
    return UserProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalXp: totalXp ?? this.totalXp,
      todayXp: todayXp ?? this.todayXp,
      level: level ?? this.level,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      wordsMastered: wordsMastered ?? this.wordsMastered,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      themeProgress: themeProgress ?? this.themeProgress,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalXp': totalXp,
        'todayXp': todayXp,
        'level': level,
        'wordsLearned': wordsLearned,
        'wordsMastered': wordsMastered,
        'lessonsCompleted': lessonsCompleted,
        'lastActivityDate': lastActivityDate?.toIso8601String(),
        'completedLessonIds': completedLessonIds,
        'themeProgress': themeProgress,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      todayXp: json['todayXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      wordsLearned: json['wordsLearned'] as int? ?? 0,
      wordsMastered: json['wordsMastered'] as int? ?? 0,
      lessonsCompleted: json['lessonsCompleted'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      themeProgress: (json['themeProgress'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
    );
  }
}
