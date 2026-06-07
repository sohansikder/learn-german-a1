import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vocabulary_word.dart';

/// Provider for vocabulary words. Uses seed data in Phase 1.
final vocabularyProvider =
    StateNotifierProvider<VocabularyNotifier, List<VocabularyWord>>(
  (ref) => VocabularyNotifier(),
);

class VocabularyNotifier extends StateNotifier<List<VocabularyWord>> {
  VocabularyNotifier() : super(_seedVocabulary);

  /// Update mastery for a word after review.
  void updateMastery(String wordId, double newMastery) {
    state = [
      for (final word in state)
        if (word.id == wordId)
          word.copyWith(
            mastery: newMastery.clamp(0.0, 1.0),
            lastReviewedAt: DateTime.now(),
            reviewCount: word.reviewCount + 1,
          )
        else
          word,
    ];
  }

  /// Get words filtered by theme.
  List<VocabularyWord> byTheme(String theme) {
    return state.where((w) => w.theme == theme).toList();
  }

  /// Get words that need review (low mastery or stale).
  List<VocabularyWord> wordsForReview() {
    return state.where((w) => w.mastery < 0.9).toList()
      ..sort((a, b) => a.mastery.compareTo(b.mastery));
  }
}

/// Seed vocabulary — 30 curated A1 words across 7 themes.
final List<VocabularyWord> _seedVocabulary = [
  // ── Begrüßung & Vorstellung ──
  VocabularyWord(id: 'v001', germanWord: 'Hallo', article: Article.none, englishTranslation: 'Hello', exampleSentence: 'Hallo, wie geht es Ihnen?', exampleTranslation: 'Hello, how are you?', theme: 'Begrüßung & Vorstellung'),
  VocabularyWord(id: 'v002', germanWord: 'Name', article: Article.der, pluralForm: 'Namen', englishTranslation: 'Name', exampleSentence: 'Mein Name ist Sohan.', exampleTranslation: 'My name is Sohan.', theme: 'Begrüßung & Vorstellung'),
  VocabularyWord(id: 'v003', germanWord: 'Frau', article: Article.die, pluralForm: 'Frauen', englishTranslation: 'Woman / Mrs.', exampleSentence: 'Die Frau liest ein Buch.', exampleTranslation: 'The woman reads a book.', theme: 'Begrüßung & Vorstellung'),
  VocabularyWord(id: 'v004', germanWord: 'Kind', article: Article.das, pluralForm: 'Kinder', englishTranslation: 'Child', exampleSentence: 'Das Kind spielt im Park.', exampleTranslation: 'The child plays in the park.', theme: 'Begrüßung & Vorstellung'),
  VocabularyWord(id: 'v005', germanWord: 'Mann', article: Article.der, pluralForm: 'Männer', englishTranslation: 'Man', exampleSentence: 'Der Mann arbeitet.', exampleTranslation: 'The man works.', theme: 'Begrüßung & Vorstellung'),

  // ── Essen & Trinken ──
  VocabularyWord(id: 'v010', germanWord: 'Brot', article: Article.das, pluralForm: 'Brote', englishTranslation: 'Bread', exampleSentence: 'Ich esse das Brot zum Frühstück.', exampleTranslation: 'I eat bread for breakfast.', theme: 'Essen & Trinken'),
  VocabularyWord(id: 'v011', germanWord: 'Wasser', article: Article.das, englishTranslation: 'Water', exampleSentence: 'Ich trinke Wasser.', exampleTranslation: 'I drink water.', theme: 'Essen & Trinken'),
  VocabularyWord(id: 'v012', germanWord: 'Kaffee', article: Article.der, englishTranslation: 'Coffee', exampleSentence: 'Der Kaffee ist heiß.', exampleTranslation: 'The coffee is hot.', theme: 'Essen & Trinken'),
  VocabularyWord(id: 'v013', germanWord: 'Milch', article: Article.die, englishTranslation: 'Milk', exampleSentence: 'Die Milch ist frisch.', exampleTranslation: 'The milk is fresh.', theme: 'Essen & Trinken'),
  VocabularyWord(id: 'v014', germanWord: 'Apfel', article: Article.der, pluralForm: 'Äpfel', englishTranslation: 'Apple', exampleSentence: 'Der Apfel ist rot.', exampleTranslation: 'The apple is red.', theme: 'Essen & Trinken'),
  VocabularyWord(id: 'v015', germanWord: 'Ei', article: Article.das, pluralForm: 'Eier', englishTranslation: 'Egg', exampleSentence: 'Ich möchte ein Ei.', exampleTranslation: 'I would like an egg.', theme: 'Essen & Trinken'),
  VocabularyWord(id: 'v016', germanWord: 'Suppe', article: Article.die, pluralForm: 'Suppen', englishTranslation: 'Soup', exampleSentence: 'Die Suppe schmeckt gut.', exampleTranslation: 'The soup tastes good.', theme: 'Essen & Trinken'),

  // ── At the Mensa ──
  VocabularyWord(id: 'v020', germanWord: 'Mensa', article: Article.die, englishTranslation: 'Cafeteria (university)', exampleSentence: 'Wir essen in der Mensa.', exampleTranslation: 'We eat in the cafeteria.', theme: 'At the Mensa'),
  VocabularyWord(id: 'v021', germanWord: 'Gericht', article: Article.das, pluralForm: 'Gerichte', englishTranslation: 'Dish / Meal', exampleSentence: 'Das Gericht ist lecker.', exampleTranslation: 'The dish is delicious.', theme: 'At the Mensa'),
  VocabularyWord(id: 'v022', germanWord: 'Teller', article: Article.der, pluralForm: 'Teller', englishTranslation: 'Plate', exampleSentence: 'Der Teller ist leer.', exampleTranslation: 'The plate is empty.', theme: 'At the Mensa'),

  // ── City Transit ──
  VocabularyWord(id: 'v030', germanWord: 'Straßenbahn', article: Article.die, pluralForm: 'Straßenbahnen', englishTranslation: 'Tram', exampleSentence: 'Die Straßenbahn fährt zum Hauptbahnhof.', exampleTranslation: 'The tram goes to the main station.', theme: 'City Transit'),
  VocabularyWord(id: 'v031', germanWord: 'Fahrschein', article: Article.der, pluralForm: 'Fahrscheine', englishTranslation: 'Ticket (transport)', exampleSentence: 'Ich brauche einen Fahrschein.', exampleTranslation: 'I need a ticket.', theme: 'City Transit'),
  VocabularyWord(id: 'v032', germanWord: 'Haltestelle', article: Article.die, pluralForm: 'Haltestellen', englishTranslation: 'Stop (bus/tram)', exampleSentence: 'Die Haltestelle ist dort.', exampleTranslation: 'The stop is over there.', theme: 'City Transit'),
  VocabularyWord(id: 'v033', germanWord: 'Fahrrad', article: Article.das, pluralForm: 'Fahrräder', englishTranslation: 'Bicycle', exampleSentence: 'Das Fahrrad ist neu.', exampleTranslation: 'The bicycle is new.', theme: 'City Transit'),

  // ── Wohnen ──
  VocabularyWord(id: 'v050', germanWord: 'Wohnung', article: Article.die, pluralForm: 'Wohnungen', englishTranslation: 'Apartment', exampleSentence: 'Die Wohnung ist groß.', exampleTranslation: 'The apartment is big.', theme: 'Wohnen'),
  VocabularyWord(id: 'v051', germanWord: 'Zimmer', article: Article.das, pluralForm: 'Zimmer', englishTranslation: 'Room', exampleSentence: 'Das Zimmer ist hell.', exampleTranslation: 'The room is bright.', theme: 'Wohnen'),
  VocabularyWord(id: 'v052', germanWord: 'Tisch', article: Article.der, pluralForm: 'Tische', englishTranslation: 'Table', exampleSentence: 'Der Tisch steht am Fenster.', exampleTranslation: 'The table is by the window.', theme: 'Wohnen'),
  VocabularyWord(id: 'v053', germanWord: 'Lampe', article: Article.die, pluralForm: 'Lampen', englishTranslation: 'Lamp', exampleSentence: 'Die Lampe ist an.', exampleTranslation: 'The lamp is on.', theme: 'Wohnen'),
  VocabularyWord(id: 'v054', germanWord: 'Bett', article: Article.das, pluralForm: 'Betten', englishTranslation: 'Bed', exampleSentence: 'Das Bett ist bequem.', exampleTranslation: 'The bed is comfortable.', theme: 'Wohnen'),

  // ── Sustainable Resources Engineering (StREaM) ──
  VocabularyWord(id: 'v040', germanWord: 'Energie', article: Article.die, englishTranslation: 'Energy', exampleSentence: 'Erneuerbare Energie ist wichtig.', exampleTranslation: 'Renewable energy is important.', theme: 'Sustainable Resources Engineering', difficulty: Difficulty.intermediate),
  VocabularyWord(id: 'v041', germanWord: 'Umwelt', article: Article.die, englishTranslation: 'Environment', exampleSentence: 'Wir schützen die Umwelt.', exampleTranslation: 'We protect the environment.', theme: 'Sustainable Resources Engineering', difficulty: Difficulty.intermediate),
  VocabularyWord(id: 'v042', germanWord: 'Nachhaltigkeit', article: Article.die, englishTranslation: 'Sustainability', exampleSentence: 'Nachhaltigkeit ist das Ziel.', exampleTranslation: 'Sustainability is the goal.', theme: 'Sustainable Resources Engineering', difficulty: Difficulty.intermediate),
  VocabularyWord(id: 'v043', germanWord: 'Rohstoff', article: Article.der, pluralForm: 'Rohstoffe', englishTranslation: 'Raw material', exampleSentence: 'Der Rohstoff wird recycelt.', exampleTranslation: 'The raw material is recycled.', theme: 'Sustainable Resources Engineering', difficulty: Difficulty.intermediate),
  VocabularyWord(id: 'v044', germanWord: 'Abfall', article: Article.der, pluralForm: 'Abfälle', englishTranslation: 'Waste', exampleSentence: 'Wir trennen den Abfall.', exampleTranslation: 'We separate the waste.', theme: 'Sustainable Resources Engineering', difficulty: Difficulty.beginner),
  VocabularyWord(id: 'v045', germanWord: 'Klima', article: Article.das, englishTranslation: 'Climate', exampleSentence: 'Das Klima verändert sich.', exampleTranslation: 'The climate is changing.', theme: 'Sustainable Resources Engineering', difficulty: Difficulty.intermediate),
];
