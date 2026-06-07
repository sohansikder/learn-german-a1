/// Constants used throughout the DeutschBlitz app.
class AppConstants {
  AppConstants._();

  // ── Gamification ──
  static const int xpPerLesson = 25;
  static const int xpPerArticleCorrect = 5;
  static const int xpPerSentenceCorrect = 15;
  static const int xpPerFlashcardMastered = 10;
  static const int dailyXpGoal = 100;
  static const int streakBonusMultiplier = 2;

  // ── Difficulty Thresholds ──
  static const double masteryThresholdLearned = 0.5;
  static const double masteryThresholdMastered = 0.9;

  // ── Spaced Repetition Intervals (in hours) ──
  static const List<int> spacedRepetitionIntervals = [1, 6, 24, 72, 168, 720];

  // ── A1 Theme Categories ──
  static const List<String> a1Themes = [
    'Begrüßung & Vorstellung',
    'Familie & Freunde',
    'Essen & Trinken',
    'At the Mensa',
    'City Transit',
    'Einkaufen',
    'Wohnen',
    'Tagesablauf',
    'Hobbys & Freizeit',
    'Körper & Gesundheit',
    'Sustainable Resources Engineering',
  ];
}
