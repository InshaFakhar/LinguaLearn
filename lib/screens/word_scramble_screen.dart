import 'dart:math';
import 'package:flutter/material.dart';
import '../data/sample_words.dart';
import '../models/word.dart';
import '../services/gamification_service.dart';

class WordScrambleScreen extends StatefulWidget {
  final String language;
  const WordScrambleScreen({super.key, required this.language});

  @override
  State<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {
  final gamification = GamificationService();
  late List<Word> gameWords;
  int currentIndex = 0;
  int score = 0;
  int roundsPlayed = 0;
  static const int totalRounds = 10;

  List<String> scrambledLetters = [];
  List<String> selectedLetters = [];
  List<int?> selectedIndexes = [];
  bool answered = false;
  bool wasCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() {
    final random = Random();
    final allWords = sampleWords
        .where((w) => w.language == widget.language && !w.isSentence && w.word.replaceAll(' ', '').length <= 10)
        .toList();
    allWords.shuffle(random);
    gameWords = allWords.take(totalRounds).toList();
    if (gameWords.isNotEmpty) {
      _setupRound();
    }
  }

  void _setupRound() {
    final word = gameWords[currentIndex].word.toUpperCase().replaceAll(' ', '');
    final letters = word.split('');
    letters.shuffle(Random());

    if (letters.join() == word) {
      letters.shuffle(Random());
    }

    setState(() {
      scrambledLetters = letters;
      selectedLetters = [];
      selectedIndexes = List.filled(letters.length, null);
      answered = false;
    });
  }

  void _selectLetter(int index) {
    if (answered) return;
    if (selectedIndexes.contains(index)) return;

    setState(() {
      selectedLetters.add(scrambledLetters[index]);
      final emptySlot = selectedIndexes.indexOf(null);
      selectedIndexes[emptySlot] = index;
    });

    if (selectedLetters.length == scrambledLetters.length) {
      _checkAnswer();
    }
  }

  void _removeLetter(int slotIndex) {
    if (answered) return;
    final letterIndex = selectedIndexes[slotIndex];
    if (letterIndex == null) return;

    setState(() {
      selectedLetters.removeAt(_positionInSelected(slotIndex));
      selectedIndexes[slotIndex] = null;
    });
  }

  int _positionInSelected(int slotIndex) {
    int count = 0;
    for (int i = 0; i < slotIndex; i++) {
      if (selectedIndexes[i] != null) count++;
    }
    return count;
  }

  Future<void> _checkAnswer() async {
    final correctWord = gameWords[currentIndex].word.toUpperCase().replaceAll(' ', '');
    final userWord = selectedLetters.join();
    final correct = userWord == correctWord;

    setState(() {
      answered = true;
      wasCorrect = correct;
      if (correct) score++;
    });

    if (correct) {
      try {
        await gamification.addXp(8);
      } catch (e) {
        debugPrint('XP error: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    _nextRound();
  }

  void _nextRound() {
    if (currentIndex < gameWords.length - 1) {
      setState(() {
        currentIndex++;
        roundsPlayed++;
      });
      _setupRound();
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over! 🎮'),
        content: Text('You scored $score out of ${gameWords.length}!\nXP earned: ${score * 8}'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (gameWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Word Scramble')),
        body: const Center(child: Text('Not enough words available for this language.')),
      );
    }

    final currentWord = gameWords[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Word Scramble - ${widget.language}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Round ${currentIndex + 1}/${gameWords.length}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                Text('Score: $score', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Hint: ${currentWord.translation}', style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 40),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(scrambledLetters.length, (i) {
                final letterIndex = selectedIndexes[i];
                final letter = letterIndex != null ? scrambledLetters[letterIndex] : '';
                Color borderColor = theme.colorScheme.outline;
                Color? bgColor;

                if (answered) {
                  bgColor = wasCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2);
                  borderColor = wasCorrect ? Colors.green : Colors.red;
                }

                return GestureDetector(
                  onTap: () => _removeLetter(i),
                  child: Container(
                    width: 42,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: bgColor,
                    ),
                    child: Text(letter, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ),

            const SizedBox(height: 50),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(scrambledLetters.length, (i) {
                final isUsed = selectedIndexes.contains(i);
                return GestureDetector(
                  onTap: isUsed ? null : () => _selectLetter(i),
                  child: Container(
                    width: 46,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isUsed ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      scrambledLetters[i],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isUsed ? Colors.transparent : Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),

            if (answered)
              Text(
                wasCorrect ? '✅ Correct!' : '❌ Answer: ${currentWord.word}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: wasCorrect ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}