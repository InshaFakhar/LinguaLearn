import 'package:flutter/material.dart';
import '../data/sample_words.dart';
import 'quiz_screen.dart';

class QuizCategoryScreen extends StatelessWidget {
  final String language;
  const QuizCategoryScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = sampleWords.where((w) => w.language == language).map((w) => w.category).toSet().toList();

    final icons = {
      'Greetings': Icons.waving_hand_rounded,
      'Vocabulary': Icons.menu_book_rounded,
      'Sentences': Icons.chat_rounded,
      'Numbers': Icons.pin_rounded,
      'Family': Icons.family_restroom_rounded,
      'Food': Icons.restaurant_rounded,
      'Days': Icons.calendar_today_rounded,
      'Colors': Icons.palette_rounded,
      'Verbs': Icons.bolt_rounded,
      'Weather': Icons.wb_sunny_rounded,
      'Body Parts': Icons.accessibility_new_rounded,
      'Clothing': Icons.checkroom_rounded,
      'Travel': Icons.flight_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Emotions': Icons.emoji_emotions_rounded,
      'Time': Icons.access_time_rounded,
      'Animals': Icons.pets_rounded,
      'Practice Sentences': Icons.auto_stories_rounded,
    };

    return Scaffold(
      appBar: AppBar(title: Text('$language Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a category to be quizzed on', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final count = sampleWords.where((w) => w.language == language && w.category == cat).length;
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(icons[cat] ?? Icons.menu_book_rounded, color: Colors.white, size: 20),
                      ),
                      title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('$count items'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => QuizScreen(language: language, category: cat)),
                        );
                      },
                    ),
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