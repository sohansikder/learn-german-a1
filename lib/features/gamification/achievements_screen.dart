import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../providers/user_progress_provider.dart';

/// Achievement definition.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final bool Function(dynamic progress) isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.isUnlocked,
  });
}

final achievements = [
  Achievement(id: 'a01', title: 'First Steps', description: 'Complete your first lesson', emoji: '🐣', color: AppColors.xpGold, isUnlocked: (p) => p.lessonsCompleted >= 1),
  Achievement(id: 'a02', title: 'Word Collector', description: 'Learn 25 words', emoji: '📖', color: AppColors.secondaryTeal, isUnlocked: (p) => p.wordsLearned >= 25),
  Achievement(id: 'a03', title: 'Word Master', description: 'Learn 50 words', emoji: '🎓', color: AppColors.primaryIndigo, isUnlocked: (p) => p.wordsLearned >= 50),
  Achievement(id: 'a04', title: 'Streak Starter', description: '3-day streak', emoji: '🔥', color: AppColors.streakOrange, isUnlocked: (p) => p.currentStreak >= 3),
  Achievement(id: 'a05', title: 'Streak Master', description: '7-day streak', emoji: '🔥', color: AppColors.streakFlame, isUnlocked: (p) => p.currentStreak >= 7),
  Achievement(id: 'a06', title: 'XP Hunter', description: 'Earn 500 XP', emoji: '⚡', color: AppColors.xpGold, isUnlocked: (p) => p.totalXp >= 500),
  Achievement(id: 'a07', title: 'XP Champion', description: 'Earn 1000 XP', emoji: '🏆', color: AppColors.xpGold, isUnlocked: (p) => p.totalXp >= 1000),
  Achievement(id: 'a08', title: 'Article Expert', description: 'Master 10 articles', emoji: '🇩🇪', color: AppColors.derBlue, isUnlocked: (p) => p.wordsMastered >= 10),
  Achievement(id: 'a09', title: 'Daily Goal', description: 'Reach 100 XP in a day', emoji: '🎯', color: AppColors.successGreen, isUnlocked: (p) => p.todayXp >= 100),
  Achievement(id: 'a10', title: 'Lesson Legend', description: 'Complete 10 lessons', emoji: '📚', color: AppColors.primaryIndigoLight, isUnlocked: (p) => p.lessonsCompleted >= 10),
];

/// Achievements / Leaderboard screen.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final isDark = context.isDarkMode;

    final unlockedCount = achievements.where((a) => a.isUnlocked(progress)).length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(onPressed: () => context.go('/'), icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary)),
                    const Spacer(),
                    Text('🏅 Achievements', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.xpGold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text('$unlockedCount/${achievements.length}', style: context.textTheme.labelLarge?.copyWith(color: AppColors.xpGold, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  dividerColor: Colors.transparent,
                  tabs: const [Tab(text: 'Badges'), Tab(text: 'Leaderboard')],
                ),
              ),

              16.verticalSpace,

              // Tab views
              Expanded(
                child: TabBarView(
                  children: [
                    _BadgesView(progress: progress),
                    _LeaderboardView(progress: progress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgesView extends StatelessWidget {
  final dynamic progress;
  const _BadgesView({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final unlocked = achievement.isUnlocked(progress);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: unlocked ? achievement.color.withValues(alpha: 0.5) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)), width: unlocked ? 2 : 1),
            boxShadow: unlocked ? [BoxShadow(color: achievement.color.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji with lock overlay
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(achievement.emoji, style: TextStyle(fontSize: 40, color: unlocked ? null : Colors.grey)),
                  if (!unlocked)
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6), shape: BoxShape.circle),
                      child: const Icon(Icons.lock_rounded, size: 22, color: Colors.grey),
                    ),
                ],
              ),
              12.verticalSpace,
              Text(achievement.title, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: unlocked ? null : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary)), textAlign: TextAlign.center),
              4.verticalSpace,
              Text(achievement.description, style: context.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary, fontSize: 11), textAlign: TextAlign.center),
              if (unlocked) ...[
                6.verticalSpace,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: achievement.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('UNLOCKED', style: context.textTheme.labelSmall?.copyWith(color: achievement.color, fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 9)),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (60 * index).ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 400.ms, delay: (60 * index).ms);
      },
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  final dynamic progress;
  const _LeaderboardView({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // Mock leaderboard data
    final leaderboard = [
      _LeaderEntry(rank: 1, name: 'Anna M.', xp: 3450, emoji: '👑', isUser: false),
      _LeaderEntry(rank: 2, name: 'Lukas K.', xp: 2890, emoji: '🥈', isUser: false),
      _LeaderEntry(rank: 3, name: 'Maria S.', xp: 2100, emoji: '🥉', isUser: false),
      _LeaderEntry(rank: 4, name: 'Sohan H.', xp: progress.totalXp, emoji: '⚡', isUser: true),
      _LeaderEntry(rank: 5, name: 'Felix W.', xp: 980, emoji: '🔥', isUser: false),
      _LeaderEntry(rank: 6, name: 'Sara L.', xp: 750, emoji: '⭐', isUser: false),
      _LeaderEntry(rank: 7, name: 'Tom B.', xp: 420, emoji: '📖', isUser: false),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: entry.isUser
                ? AppColors.primaryIndigo.withValues(alpha: 0.1)
                : (isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard),
            borderRadius: BorderRadius.circular(16),
            border: entry.isUser
                ? Border.all(color: AppColors.primaryIndigo.withValues(alpha: 0.4), width: 2)
                : Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 32,
                child: Text(
                  entry.rank <= 3 ? ['🥇', '🥈', '🥉'][entry.rank - 1] : '#${entry.rank}',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              12.horizontalSpace,
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: entry.isUser ? AppColors.primaryIndigo.withValues(alpha: 0.2) : (isDark ? AppColors.surfaceDarkDialog : AppColors.surfaceLightElevated),
                child: Text(entry.emoji, style: const TextStyle(fontSize: 18)),
              ),
              12.horizontalSpace,
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: context.textTheme.titleSmall?.copyWith(fontWeight: entry.isUser ? FontWeight.w800 : FontWeight.w600)),
                    if (entry.isUser)
                      Text('You', style: context.textTheme.bodySmall?.copyWith(color: AppColors.primaryIndigo, fontWeight: FontWeight.w600, fontSize: 11)),
                  ],
                ),
              ),
              // XP
              Text('${entry.xp} XP', style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: entry.isUser ? AppColors.primaryIndigo : AppColors.xpGold)),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (80 * index).ms).slideX(begin: 0.1, end: 0, duration: 300.ms, delay: (80 * index).ms);
      },
    );
  }
}

class _LeaderEntry {
  final int rank;
  final String name;
  final int xp;
  final String emoji;
  final bool isUser;

  const _LeaderEntry({required this.rank, required this.name, required this.xp, required this.emoji, required this.isUser});
}
