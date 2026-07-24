import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/gamification_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = GamificationService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: StreamBuilder(
        stream: gamification.statsStream(),
        builder: (context, snapshot) {
          final data = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};
          final unlockedIds = gamification.getUnlockedAchievementIds(data);

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: allAchievements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final achievement = allAchievements[i];
              final isUnlocked = unlockedIds.contains(achievement.id);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Opacity(
                      opacity: isUnlocked ? 1.0 : 0.3,
                      child: Text(achievement.emoji, style: const TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? null : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            achievement.description,
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(Icons.check_circle_rounded, color: Colors.green)
                    else
                      Icon(Icons.lock_outline_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}