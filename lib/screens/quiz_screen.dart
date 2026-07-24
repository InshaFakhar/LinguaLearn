import 'dart:math';
import 'package:flutter/material.dart';
import '../data/sample_words.dart';
import '../models/quiz_question.dart';
import '../services/storage_service.dart';
import '../services/gamification_service.dart';

class QuizScreen extends StatefulWidget {
  final String language;
  final String category;
  const QuizScreen({super.key, required this.language, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> questions;
  int currentIndex = 0;
  int score = 0;
  String? selectedOption;
  bool answered = false;
  final storage = StorageService();
  final gamification = GamificationService();

  @override
  void initState() {
    super.initState();
    questions = _generateQuestions();
  }

  List<QuizQuestion> _generateQuestions() {
    final words = sampleWords.where((w) => w.language == widget.language && w.category == widget.category).toList();
    final allLanguageWords = sampleWords.where((w) => w.language == widget.language).toList();
    final random = Random();

    final shuffled = List.of(words)..shuffle(random);
    final limited = shuffled.take(15).toList(); // max 15 questions per quiz

    return limited.map((w) {
      List<String> options = [w.translation];
      while (options.length < 3) {
        final randomWord = allLanguageWords[random.nextInt(allLanguageWords.length)].translation;
        if (!options.contains(randomWord)) options.add(randomWord);
      }
      options.shuffle();
      return QuizQuestion(question: w.word, options: options, correctAnswer: w.translation);
    }).toList();
  }

  void _selectOption(String option) async {
    if (answered) return;
    setState(() {
      selectedOption = option;
      answered = true;
      if (option == questions[currentIndex].correctAnswer) score++;
    });
  }

  void _nextQuestion() async {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        answered = false;
      });
    } else {
      try {
        await storage.saveQuizResult(score, questions.length);
        await gamification.addXp(score * 15);
      } catch (e) {
        debugPrint('Gamification error: $e');
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quiz Complete!'),
            content: Text('Your score: $score / ${questions.length}\nXP earned: ${score * 15}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.category} Quiz')),
        body: const Center(child: Text('Not enough words in this category for a quiz.')),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} - ${widget.language}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${currentIndex + 1} / ${questions.length}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Text('What does "${q.question}" mean?', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ...q.options.map((opt) {
              Color? color;
              if (answered) {
                if (opt == q.correctAnswer) {
                  color = Colors.green;
                } else if (opt == selectedOption) {
                  color = Colors.red;
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _selectOption(opt),
                  child: Text(opt),
                ),
              );
            }),
            const Spacer(),
            if (answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(currentIndex < questions.length - 1 ? 'Next Question' : 'Finish Quiz'),
              ),
          ],
        ),
      ),
    );
  }
}