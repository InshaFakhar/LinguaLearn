import 'package:flutter/material.dart';
import '../services/revision_service.dart';
import '../services/tts_service.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  final revisionService = RevisionService();
  final tts = TtsService();
  List<Map<String, dynamic>> dueWords = [];
  int currentIndex = 0;
  bool showAnswer = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDueWords();
  }

  Future<void> _loadDueWords() async {
    final words = await revisionService.getDueWords();
    setState(() {
      dueWords = words;
      isLoading = false;
    });
  }

  Future<void> _rateWord(int rating) async {
    final word = dueWords[currentIndex];
    await revisionService.reviewWord(word['id'], rating);

    if (currentIndex < dueWords.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Revision Complete! 🎉'),
            content: Text('You reviewed ${dueWords.length} words today.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (dueWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Today\'s Revision')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('All caught up!', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('No words due for revision today', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    final word = dueWords[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Revision (${currentIndex + 1}/${dueWords.length})')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showAnswer = !showAnswer),
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
                              Text(word['word'] ?? '', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                              if (showAnswer)
                                Text(word['translation'] ?? '', style: const TextStyle(fontSize: 22, color: Colors.deepPurple), textAlign: TextAlign.center)
                              else
                                const Text('(Tap to reveal answer)', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton.filledTonal(
                          icon: const Icon(Icons.volume_up_rounded),
                          onPressed: () => tts.speak(word['word'] ?? '', word['language'] ?? 'English'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (showAnswer)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _rateWord(0),
                      child: const Text('Again'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () => _rateWord(1),
                      child: const Text('Hard'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                      onPressed: () => _rateWord(2),
                      child: const Text('Good'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => _rateWord(3),
                      child: const Text('Easy'),
                    ),
                  ),
                ],
              )
            else
              const Text('Tap the card to see the answer', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}