import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sync_service.dart';

class StorageService {
  static const String _learnedWordsKey = 'learned_words';
  static const String _quizScoreKey = 'quiz_score';
  static const String _quizAttemptsKey = 'quiz_attempts';

  Future<void> markWordLearned(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> learned = prefs.getStringList(_learnedWordsKey) ?? [];
    if (!learned.contains(wordId)) {
      learned.add(wordId);
      await prefs.setStringList(_learnedWordsKey, learned);
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('learnedWords')
          .doc(wordId)
          .set({'learnedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      await SyncService().queueOrSync('mark_word_learned', {'wordId': wordId});
    }
  }

  Future<List<String>> getLearnedWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_learnedWordsKey) ?? [];
  }

  Future<void> saveQuizResult(int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    int prevScore = prefs.getInt(_quizScoreKey) ?? 0;
    int attempts = prefs.getInt(_quizAttemptsKey) ?? 0;
    await prefs.setInt(_quizScoreKey, prevScore + score);
    await prefs.setInt(_quizAttemptsKey, attempts + 1);
  }

  Future<Map<String, int>> getQuizStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalScore': prefs.getInt(_quizScoreKey) ?? 0,
      'attempts': prefs.getInt(_quizAttemptsKey) ?? 0,
    };
  }

  Future<void> saveLastPosition(String language, String category, int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_pos_${language}_$category', index);
  }

  Future<int> getLastPosition(String language, String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_pos_${language}_$category') ?? 0;
  }
}