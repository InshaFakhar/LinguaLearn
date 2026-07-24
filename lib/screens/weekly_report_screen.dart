import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gamification_service.dart';
import '../services/storage_service.dart';
import 'heatmap_screen.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  final gamification = GamificationService();
  final storage = StorageService();
  List<Map<String, dynamic>> weeklyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await gamification.getLast7DaysActivity();
    setState(() {
      weeklyData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final maxXp = weeklyData.map((d) => d['xp'] as int).fold(0, (a, b) => a > b ? a : b);
    final totalWeekXp = weeklyData.fold(0, (sum, d) => sum + (d['xp'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_month_rounded),
            tooltip: 'View Heatmap',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HeatmapScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Week', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('$totalWeekXp XP earned', style: TextStyle(color: theme.colorScheme.primary, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  maxY: (maxXp == 0 ? 10 : maxXp * 1.3).toDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= weeklyData.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(weeklyData[index]['day'], style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(weeklyData.length, (i) {
                    final xp = weeklyData[i]['xp'] as int;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: xp.toDouble(),
                          color: theme.colorScheme.primary,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 28),
            Text('Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            StreamBuilder<DocumentSnapshot>(
              stream: gamification.statsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final words = data['totalWordsLearned'] ?? 0;
                final streak = data['streak'] ?? 0;
                final xp = data['xp'] ?? 0;
                final level = gamification.getLevel(xp);

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _SummaryCard(icon: Icons.menu_book_rounded, label: 'Total Words', value: '$words', color: Colors.green),
                    _SummaryCard(icon: Icons.local_fire_department_rounded, label: 'Current Streak', value: '$streak days', color: Colors.orange),
                    _SummaryCard(icon: Icons.bolt_rounded, label: 'Total XP', value: '$xp', color: Colors.blue),
                    _SummaryCard(icon: Icons.star_rounded, label: 'Level', value: '$level', color: Colors.purple),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}