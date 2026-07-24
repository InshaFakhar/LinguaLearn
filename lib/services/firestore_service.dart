import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> markWordLearned(String wordId) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('learnedWords').doc(wordId).set({
      'learnedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<String>> getLearnedWords() {
    if (_uid == null) return const Stream.empty();
    return _db.collection('users').doc(_uid).collection('learnedWords').snapshots().map(
          (snap) => snap.docs.map((d) => d.id).toList(),
    );
  }

  Future<void> saveQuizResult(int score, int total) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('quizResults').add({
      'score': score,
      'total': total,
      'date': FieldValue.serverTimestamp(),
    });
  }
}