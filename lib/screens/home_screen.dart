import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/sample_words.dart';
import '../services/gamification_service.dart';
import '../services/revision_service.dart';
import 'flashcard_screen.dart';
import 'categories_screen.dart';
import 'revision_screen.dart';
import 'word_scramble_screen.dart';
import 'practice_sentences_screen.dart';

class HomeScreen extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChange;

  const HomeScreen({super.key, required this.selectedLanguage, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    final languages = ['Spanish', 'French', 'Italian', 'Urdu', 'English'];
    final categories = sampleWords.where((w) => w.language == selectedLanguage).map((w) => w.category).toSet().toList();
    final theme = Theme.of(context);
    final gamification = GamificationService();

    final icons = {
      'Clothing': Icons.checkroom_rounded,
      'Travel': Icons.flight_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Emotions': Icons.emoji_emotions_rounded,
      'Time': Icons.access_time_rounded,
      'Animals': Icons.pets_rounded,
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
    };

    return SafeArea(
      child: Builder(
        builder: (context) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello 👋', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      Text('Let\'s learn $selectedLanguage', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Streak + XP Card
              StreamBuilder<DocumentSnapshot>(
                stream: gamification.statsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final xp = data['xp'] ?? 0;
                  final streak = data['streak'] ?? 0;
                  final level = gamification.getLevel(xp);
                  final progress = gamification.getLevelProgress(xp);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 26),
                            Text('$streak', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text('day streak', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Level $level', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('$xp XP', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: theme.colorScheme.surface,
                                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              FutureBuilder<int>(
                future: RevisionService().getDueCount(),
                builder: (context, snapshot) {
                  final dueCount = snapshot.data ?? 0;
                  if (dueCount == 0) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevisionScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.refresh_rounded, color: Colors.orange, size: 26),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Today\'s Revision', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('$dueCount words due for review', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              Text('Choose a language', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final lang = languages[i];
                    final isSelected = lang == selectedLanguage;
                    return ChoiceChip(
                      label: Text(lang),
                      selected: isSelected,
                      onSelected: (_) => onLanguageChange(lang),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategoriesScreen(language: selectedLanguage)),
                    ),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: categories.take(4).map((cat) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardScreen(language: selectedLanguage, category: cat))),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(icons[cat] ?? Icons.menu_book_rounded, color: theme.colorScheme.primary, size: 28),
                          Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('${sampleWords.where((w) => w.language == selectedLanguage && w.category == cat).length} items', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),
              Text('Practice Sentences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeSentencesScreen(language: selectedLanguage))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Real-world Sentences', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Thousands of practice sentences', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Text('Mini Games', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WordScrambleScreen(language: selectedLanguage))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.65)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.extension_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Word Scramble', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 2),
                            Text('Unscramble letters to form words', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Play', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}