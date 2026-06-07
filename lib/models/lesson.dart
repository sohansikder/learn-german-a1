/// Represents a lesson unit within the app.
class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String theme;
  final LessonType type;
  final int xpReward;
  final int estimatedMinutes;
  final String iconEmoji;
  final bool isLocked;
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.theme,
    required this.type,
    this.xpReward = 25,
    this.estimatedMinutes = 5,
    this.iconEmoji = '📚',
    this.isLocked = false,
    this.isCompleted = false,
  });

  Lesson copyWith({
    bool? isLocked,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id,
      title: title,
      subtitle: subtitle,
      theme: theme,
      type: type,
      xpReward: xpReward,
      estimatedMinutes: estimatedMinutes,
      iconEmoji: iconEmoji,
      isLocked: isLocked ?? this.isLocked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Types of lessons available in the app.
enum LessonType {
  articleTrainer('Article Trainer', '🎯'),
  sentenceBuilder('Sentence Builder', '🧩'),
  flashcards('Vocabulary Deck', '🃏'),
  quiz('Quick Quiz', '❓'),
  review('Review Session', '🔄');

  const LessonType(this.label, this.emoji);

  final String label;
  final String emoji;
}
