import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../services/gamification_service.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final gamification = GamificationService();
  Map<DateTime, int> activityData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await gamification.getAllActivityHistory();
    setState(() {
      activityData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalDays = activityData.length;
    final totalXp = activityData.values.fold(0, (sum, xp) => sum + xp);
    final bestDay = activityData.values.isEmpty ? 0 : activityData.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Learning Heatmap')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your activity over time', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: HeatMap(
                datasets: activityData,
                colorMode: ColorMode.opacity,
                showText: false,
                scrollable: true,
                size: 22,
                colorsets: {
                  1: theme.colorScheme.primary,
                },
                onClick: (date) {
                  final xp = activityData[date] ?? 0;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${date.day}/${date.month}/${date.year}: $xp XP earned')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _StatBox(label: 'Active Days', value: '$totalDays', icon: Icons.calendar_month_rounded, color: Colors.blue),
                _StatBox(label: 'Total XP', value: '$totalXp', icon: Icons.bolt_rounded, color: Colors.orange),
                _StatBox(label: 'Best Day', value: '$bestDay XP', icon: Icons.emoji_events_rounded, color: Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}