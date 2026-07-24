import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import 'weekly_report_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = GamificationService();
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Progress', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.bar_chart_rounded, size: 18),
                  label: const Text('Weekly Report'),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyReportScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: gamification.statsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final xp = data['xp'] ?? 0;
                  final streak = data['streak'] ?? 0;
                  final longestStreak = data['longestStreak'] ?? 0;
                  final wordsLearned = data['totalWordsLearned'] ?? 0;
                  final level = gamification.getLevel(xp);

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.3,
                    children: [
                      _StatCard(icon: Icons.local_fire_department_rounded, color: Colors.orange, label: 'Current Streak', value: '$streak days'),
                      _StatCard(icon: Icons.emoji_events_rounded, color: Colors.amber, label: 'Best Streak', value: '$longestStreak days'),
                      _StatCard(icon: Icons.star_rounded, color: Colors.purple, label: 'Level', value: '$level'),
                      _StatCard(icon: Icons.bolt_rounded, color: Colors.blue, label: 'Total XP', value: '$xp'),
                      _StatCard(icon: Icons.menu_book_rounded, color: Colors.green, label: 'Words Learned', value: '$wordsLearned'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}