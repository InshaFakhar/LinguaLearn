import 'package:flutter/material.dart';
import '../data/sample_words.dart';
import '../services/storage_service.dart';
import '../services/gamification_service.dart';
import '../services/tts_service.dart';
import '../services/favorites_service.dart';
import '../services/revision_service.dart';

class FlashcardScreen extends StatefulWidget {
  final String language;
  final String category;
  const FlashcardScreen({super.key, required this.language, required this.category});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
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
    _loadLastPosition();
  }

  Future<void> _loadLastPosition() async {
    final savedIndex = await storage.getLastPosition(widget.language, widget.category);
    final words = sampleWords.where((w) => w.language == widget.language && w.category == widget.category).toList();

    setState(() {
      currentIndex = (savedIndex < words.length) ? savedIndex : 0;
      isLoading = false;
    });
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final words = sampleWords.where((w) => w.language == widget.language && w.category == widget.category).toList();
    if (words.isEmpty) return;
    final word = words[currentIndex];
    final fav = await favorites.isFavorite(word.id);
    if (mounted) setState(() => isFavorited = fav);
  }

  void _saveProgress() {
    storage.saveLastPosition(widget.language, widget.category, currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final words = sampleWords
        .where((w) => w.language == widget.language && w.category == widget.category)
        .toList();

    final word = words[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.language}'),
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
                              Text(word.word, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              if (word.pronunciation.isNotEmpty)
                                Text('/${word.pronunciation}/', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)),
                              const SizedBox(height: 20),
                              if (showTranslation)
                                Text(word.translation, style: const TextStyle(fontSize: 24, color: Colors.deepPurple), textAlign: TextAlign.center),
                              if (!showTranslation)
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
                          icon: Icon(
                            isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorited ? Colors.red : null,
                          ),
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
                      await gamification.addXp(10);
                      await gamification.incrementWordsLearned();
                    } catch (e) {
                      debugPrint('Gamification error: $e');
                    }

                    if (currentIndex < words.length - 1) {
                      setState(() {
                        currentIndex++;
                        showTranslation = false;
                      });
                      _saveProgress();
                      _checkFavorite();
                    } else {
                      await storage.saveLastPosition(widget.language, widget.category, 0);
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