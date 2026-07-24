import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevisionService {
  final _db = FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _revisionRef => _db.collection('users').doc(_uid).collection('revisions');

  // Jab pehli baar word seekha jaye, revision schedule shuru karo
  Future<void> initializeRevision(String wordId, Map<String, dynamic> wordData) async {
    if (_uid == null) return;
    final doc = await _revisionRef.doc(wordId).get();
    if (doc.exists) return; // already schedule me hai

    final tomorrow = DateTime.now().add(const Duration(days: 1));

    await _revisionRef.doc(wordId).set({
      ...wordData,
      'reviewCount': 0,
      'easeFactor': 2.5,
      'interval': 1,
      'nextReviewDate': tomorrow.toIso8601String(),
      'lastReviewed': null,
    });
  }

  // User ne review kiya, rating ke hisab se next date calculate karo
  // rating: 0 = Again, 1 = Hard, 2 = Good, 3 = Easy
  Future<void> reviewWord(String wordId, int rating) async {
    if (_uid == null) return;
    final doc = await _revisionRef.doc(wordId).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    double easeFactor = (data['easeFactor'] ?? 2.5).toDouble();
    int interval = data['interval'] ?? 1;
    int reviewCount = data['reviewCount'] ?? 0;

    if (rating == 0) {
      // Again - turant wapas revision me
      interval = 1;
      easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0);
    } else {
      reviewCount++;
      if (rating == 1) {
        // Hard
        easeFactor = (easeFactor - 0.15).clamp(1.3, 3.0);
        interval = (interval * 1.2).ceil();
      } else if (rating == 2) {
        // Good
        interval = (interval * easeFactor).ceil();
      } else {
        // Easy
        easeFactor = (easeFactor + 0.15).clamp(1.3, 3.0);
        interval = (interval * easeFactor * 1.3).ceil();
      }
    }

    final nextReviewDate = DateTime.now().add(Duration(days: interval));

    await _revisionRef.doc(wordId).update({
      'reviewCount': reviewCount,
      'easeFactor': easeFactor,
      'interval': interval,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'lastReviewed': DateTime.now().toIso8601String(),
    });
  }

  // Aaj ke due words fetch karo
  Future<List<Map<String, dynamic>>> getDueWords() async {
    if (_uid == null) return [];
    final now = DateTime.now();

    final snapshot = await _revisionRef.get();
    final dueWords = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final nextReviewStr = data['nextReviewDate'] as String?;
      if (nextReviewStr == null) continue;

      final nextReview = DateTime.parse(nextReviewStr);
      if (nextReview.isBefore(now) || nextReview.isAtSameMomentAs(now)) {
        dueWords.add({...data, 'id': doc.id});
      }
    }

    return dueWords;
  }

  Future<int> getDueCount() async {
    final due = await getDueWords();
    return due.length;
  }
}