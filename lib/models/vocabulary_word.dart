/// German grammatical article.
enum Article {
  der('der', 'Masculine'),
  die('die', 'Feminine'),
  das('das', 'Neuter'),
  none('', 'No article');

  const Article(this.label, this.genderName);

  final String label;
  final String genderName;
}

/// Difficulty level for vocabulary and grammar content.
enum Difficulty {
  beginner,
  intermediate,
  advanced,
}

/// Represents a single German vocabulary word with metadata for
/// spaced repetition, theming, and article training.
class VocabularyWord {
  final String id;
  final String germanWord;
  final Article article;
  final String pluralForm;
  final String englishTranslation;
  final String exampleSentence;
  final String exampleTranslation;
  final String theme;
  final Difficulty difficulty;
  final String? audioUrl;
  final String? imageUrl;
  double mastery; // 0.0 to 1.0 — spaced repetition score
  DateTime? lastReviewedAt;
  int reviewCount;

  VocabularyWord({
    required this.id,
    required this.germanWord,
    required this.article,
    this.pluralForm = '',
    required this.englishTranslation,
    this.exampleSentence = '',
    this.exampleTranslation = '',
    required this.theme,
    this.difficulty = Difficulty.beginner,
    this.audioUrl,
    this.imageUrl,
    this.mastery = 0.0,
    this.lastReviewedAt,
    this.reviewCount = 0,
  });

  /// Whether this word has been fully mastered.
  bool get isMastered => mastery >= 0.9;

  /// Whether this word is currently being learned.
  bool get isLearning => mastery >= 0.5 && mastery < 0.9;

  /// Whether this word is new / not yet started.
  bool get isNew => mastery < 0.5;

  /// Display string: "der Tisch", "die Lampe", etc.
  String get displayWord {
    if (article == Article.none) return germanWord;
    return '${article.label} $germanWord';
  }

  /// Create a copy with updated fields.
  VocabularyWord copyWith({
    double? mastery,
    DateTime? lastReviewedAt,
    int? reviewCount,
  }) {
    return VocabularyWord(
      id: id,
      germanWord: germanWord,
      article: article,
      pluralForm: pluralForm,
      englishTranslation: englishTranslation,
      exampleSentence: exampleSentence,
      exampleTranslation: exampleTranslation,
      theme: theme,
      difficulty: difficulty,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      mastery: mastery ?? this.mastery,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  /// Serialize to JSON map (for Hive / API).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'germanWord': germanWord,
      'article': article.name,
      'pluralForm': pluralForm,
      'englishTranslation': englishTranslation,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'theme': theme,
      'difficulty': difficulty.name,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'mastery': mastery,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'reviewCount': reviewCount,
    };
  }

  /// Deserialize from JSON map.
  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as String,
      germanWord: json['germanWord'] as String,
      article: Article.values.firstWhere((a) => a.name == json['article']),
      pluralForm: json['pluralForm'] as String? ?? '',
      englishTranslation: json['englishTranslation'] as String,
      exampleSentence: json['exampleSentence'] as String? ?? '',
      exampleTranslation: json['exampleTranslation'] as String? ?? '',
      theme: json['theme'] as String,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0.0,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'VocabularyWord($displayWord → $englishTranslation)';
}
