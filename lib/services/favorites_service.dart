import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final _db = FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _favRef => _db.collection('users').doc(_uid).collection('favorites');

  Future<void> toggleFavorite(String wordId, Map<String, dynamic> wordData) async {
    if (_uid == null) return;
    final doc = await _favRef.doc(wordId).get();
    if (doc.exists) {
      await _favRef.doc(wordId).delete();
    } else {
      await _favRef.doc(wordId).set(wordData);
    }
  }

  Future<bool> isFavorite(String wordId) async {
    if (_uid == null) return false;
    final doc = await _favRef.doc(wordId).get();
    return doc.exists;
  }

  Stream<QuerySnapshot> favoritesStream() {
    return _favRef.snapshots();
  }
}