/// Represents a single example for a grammar rule — a correct sentence
/// and optionally an incorrect variant for comparison.
class GrammarExample {
  final String correctSentence;
  final String incorrectSentence;
  final String explanation;
  final String translation;

  const GrammarExample({
    required this.correctSentence,
    this.incorrectSentence = '',
    this.explanation = '',
    this.translation = '',
  });

  Map<String, dynamic> toJson() => {
        'correctSentence': correctSentence,
        'incorrectSentence': incorrectSentence,
        'explanation': explanation,
        'translation': translation,
      };

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      correctSentence: json['correctSentence'] as String,
      incorrectSentence: json['incorrectSentence'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
    );
  }
}

/// Represents a German grammar rule with visual formula representation
/// and tagged examples for the Sentence Builder module.
class GrammarRule {
  final String id;
  final String ruleName;
  final String description;
  final String formula; // e.g., "[S] [V] [O] [T] [P]"
  final List<GrammarExample> examples;
  final String level; // CEFR level: A1, A2
  final List<String> tags;
  final String? tipEmoji; // Fun emoji for display
  final String? mnemonicTip; // Memory aid

  const GrammarRule({
    required this.id,
    required this.ruleName,
    required this.description,
    required this.formula,
    this.examples = const [],
    this.level = 'A1',
    this.tags = const [],
    this.tipEmoji,
    this.mnemonicTip,
  });

  /// Create a copy with updated fields.
  GrammarRule copyWith({
    List<GrammarExample>? examples,
    List<String>? tags,
  }) {
    return GrammarRule(
      id: id,
      ruleName: ruleName,
      description: description,
      formula: formula,
      examples: examples ?? this.examples,
      level: level,
      tags: tags ?? this.tags,
      tipEmoji: tipEmoji,
      mnemonicTip: mnemonicTip,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ruleName': ruleName,
        'description': description,
        'formula': formula,
        'examples': examples.map((e) => e.toJson()).toList(),
        'level': level,
        'tags': tags,
        'tipEmoji': tipEmoji,
        'mnemonicTip': mnemonicTip,
      };

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      id: json['id'] as String,
      ruleName: json['ruleName'] as String,
      description: json['description'] as String,
      formula: json['formula'] as String,
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      level: json['level'] as String? ?? 'A1',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
      tipEmoji: json['tipEmoji'] as String?,
      mnemonicTip: json['mnemonicTip'] as String?,
    );
  }

  @override
  String toString() => 'GrammarRule($ruleName [$level])';
}
