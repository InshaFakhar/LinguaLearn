import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference get _profileRef => _db.collection('users').doc(_uid).collection('profile').doc('info');

  Future<Map<String, dynamic>> getProfile() async {
    if (_uid == null) return {};
    final doc = await _profileRef.get();
    if (!doc.exists) {
      final defaultData = {
        'name': FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'User',
        'avatarColor': 0xFF7C6BA8,
      };
      await _profileRef.set(defaultData);
      return defaultData;
    }
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> updateName(String name) async {
    if (_uid == null) return;
    await _profileRef.set({'name': name}, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> profileStream() {
    return _profileRef.snapshots();
  }
}