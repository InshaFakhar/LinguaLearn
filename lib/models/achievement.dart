class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requiredValue;
  final String type; // 'streak', 'words', 'xp', 'quiz'

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requiredValue,
    required this.type,
  });
}

final List<Achievement> allAchievements = [
  Achievement(id: 'streak_3', title: 'Getting Started', description: '3 day streak', emoji: '🔥', requiredValue: 3, type: 'streak'),
  Achievement(id: 'streak_7', title: 'Week Warrior', description: '7 day streak', emoji: '⚡', requiredValue: 7, type: 'streak'),
  Achievement(id: 'streak_30', title: 'Unstoppable', description: '30 day streak', emoji: '🏆', requiredValue: 30, type: 'streak'),

  Achievement(id: 'words_10', title: 'First Steps', description: 'Learn 10 words', emoji: '📖', requiredValue: 10, type: 'words'),
  Achievement(id: 'words_50', title: 'Word Collector', description: 'Learn 50 words', emoji: '📚', requiredValue: 50, type: 'words'),
  Achievement(id: 'words_100', title: 'Vocabulary Master', description: 'Learn 100 words', emoji: '🎓', requiredValue: 100, type: 'words'),

  Achievement(id: 'xp_100', title: 'Level Up', description: 'Reach 100 XP', emoji: '⭐', requiredValue: 100, type: 'xp'),
  Achievement(id: 'xp_500', title: 'Rising Star', description: 'Reach 500 XP', emoji: '🌟', requiredValue: 500, type: 'xp'),
  Achievement(id: 'xp_1000', title: 'Language Champion', description: 'Reach 1000 XP', emoji: '👑', requiredValue: 1000, type: 'xp'),
];