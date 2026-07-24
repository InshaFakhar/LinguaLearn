import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/practice_sentences_loader.dart';
import '../services/storage_service.dart';
import '../services/gamification_service.dart';
import '../services/tts_service.dart';
import '../services/favorites_service.dart';
import '../services/revision_service.dart';

class PracticeSentencesScreen extends StatefulWidget {
  final String language;
  const PracticeSentencesScreen({super.key, required this.language});

  @override
  State<PracticeSentencesScreen> createState() => _PracticeSentencesScreenState();
}

class _PracticeSentencesScreenState extends State<PracticeSentencesScreen> {
  List<Word> words = [];
  int currentIndex = 0;
  bool showTranslation = false;
  bool isFavorited = false;
  bool isLoading = true;

  final storage = StorageService();
  final gamification = GamificationService();
  final tts = TtsService();
  final favorites = FavoritesService();
  final revisionService = RevisionService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await PracticeSentencesLoader.load(widget.language);
    final savedIndex = await storage.getLastPosition(widget.language, 'Practice Sentences');

    setState(() {
      words = loaded;
      currentIndex = (savedIndex < loaded.length) ? savedIndex : 0;
      isLoading = false;
    });
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    if (words.isEmpty) return;
    final fav = await favorites.isFavorite(words[currentIndex].id);
    if (mounted) setState(() => isFavorited = fav);
  }

  void _saveProgress() {
    storage.saveLastPosition(widget.language, 'Practice Sentences', currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Practice Sentences - ${widget.language}')),
        body: const Center(child: Text('No sentences available.')),
      );
    }

    final word = words[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Sentences - ${widget.language}'),
        actions: [
          if (currentIndex > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  currentIndex = 0;
                  showTranslation = false;
                });
                _saveProgress();
                _checkFavorite();
              },
              child: const Text('Restart'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showTranslation = !showTranslation),
                child: Card(
                  elevation: 4,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(word.word, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                              if (showTranslation)
                                Text(word.translation, style: const TextStyle(fontSize: 20, color: Colors.deepPurple), textAlign: TextAlign.center)
                              else
                                const Text('(Tap card to reveal meaning)', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton.filledTonal(
                          icon: const Icon(Icons.volume_up_rounded),
                          onPressed: () => tts.speak(word.word, widget.language),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: IconButton.filledTonal(
                          icon: Icon(isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorited ? Colors.red : null),
                          onPressed: () async {
                            await favorites.toggleFavorite(word.id, {
                              'word': word.word,
                              'translation': word.translation,
                              'pronunciation': word.pronunciation,
                              'language': word.language,
                              'category': word.category,
                            });
                            setState(() => isFavorited = !isFavorited);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0
                      ? () {
                    setState(() {
                      currentIndex--;
                      showTranslation = false;
                    });
                    _saveProgress();
                    _checkFavorite();
                  }
                      : null,
                  child: const Text('Previous'),
                ),
                Text('${currentIndex + 1} / ${words.length}'),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await storage.markWordLearned(word.id);
                      await revisionService.initializeRevision(word.id, {
                        'word': word.word,
                        'translation': word.translation,
                        'pronunciation': word.pronunciation,
                        'language': word.language,
                        'category': word.category,
                      });
                      await gamification.addXp(5);
                      await gamification.incrementWordsLearned();
                    } catch (e) {
                      debugPrint('Error: $e');
                    }

                    if (currentIndex < words.length - 1) {
                      setState(() {
                        currentIndex++;
                        showTranslation = false;
                      });
                      _saveProgress();
                      _checkFavorite();
                    } else {
                      await storage.saveLastPosition(widget.language, 'Practice Sentences', 0);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}