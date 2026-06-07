import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/article_trainer/article_trainer_screen.dart';
import '../../features/vocabulary_decks/deck_list_screen.dart';
import '../../features/vocabulary_decks/deck_detail_screen.dart';
import '../../features/sentence_builder/sentence_builder_screen.dart';
import '../../features/gamification/achievements_screen.dart';

/// GoRouter configuration provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(state.uri.toString(), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/article-trainer',
        name: 'articleTrainer',
        builder: (context, state) => const ArticleTrainerScreen(),
      ),
      GoRoute(
        path: '/vocabulary-decks',
        name: 'vocabularyDecks',
        builder: (context, state) => const DeckListScreen(),
      ),
      GoRoute(
        path: '/vocabulary-decks/detail',
        name: 'deckDetail',
        builder: (context, state) {
          final theme = state.extra as String? ?? 'Begrüßung & Vorstellung';
          return DeckDetailScreen(theme: theme);
        },
      ),
      GoRoute(
        path: '/sentence-builder',
        name: 'sentenceBuilder',
        builder: (context, state) => const SentenceBuilderScreen(),
      ),
      GoRoute(
        path: '/achievements',
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
    ],
  );
});
