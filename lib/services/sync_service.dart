import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_db_service.dart';
import 'connectivity_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _localDb = LocalDbService();
  final _connectivity = ConnectivityService();
  bool _isSyncing = false;

  void startListening() {
    _connectivity.onConnectivityChanged().listen((isOnline) {
      if (isOnline) {
        syncPendingActions();
      }
    });
  }

  Future<void> syncPendingActions() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _isSyncing = false;
        return;
      }

      final pending = await _localDb.getPendingSyncs();
      if (pending.isEmpty) {
        _isSyncing = false;
        return;
      }

      final db = FirebaseFirestore.instance;

      for (var item in pending) {
        final actionType = item['action_type'] as String;
        final data = jsonDecode(item['data'] as String);
        final id = item['id'] as int;

        try {
          switch (actionType) {
            case 'add_xp':
              await db.collection('users').doc(uid).collection('stats').doc('gamification').set(
                data,
                SetOptions(merge: true),
              );
              break;
            case 'mark_word_learned':
              await db.collection('users').doc(uid).collection('learnedWords').doc(data['wordId']).set({
                'learnedAt': FieldValue.serverTimestamp(),
              });
              break;
            case 'toggle_favorite':
              final favRef = db.collection('users').doc(uid).collection('favorites').doc(data['wordId']);
              if (data['isAdding'] == true) {
                await favRef.set(data['wordData']);
              } else {
                await favRef.delete();
              }
              break;
          }
          await _localDb.removePendingSync(id);
        } catch (e) {
          // agar ek item sync fail ho, baaki try karte raho
          continue;
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> isOnline() => _connectivity.isOnline();

  Future<void> queueOrSync(String actionType, Map<String, dynamic> data) async {
    final online = await isOnline();
    if (online) {
      // seedha Firestore try karo
      final synced = await _tryDirectSync(actionType, data);
      if (!synced) {
        await _localDb.addPendingSync(actionType, jsonEncode(data));
      }
    } else {
      // offline hai, local queue me daal do
      await _localDb.addPendingSync(actionType, jsonEncode(data));
    }
  }

  Future<bool> _tryDirectSync(String actionType, Map<String, dynamic> data) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;
      final db = FirebaseFirestore.instance;

      switch (actionType) {
        case 'add_xp':
          await db.collection('users').doc(uid).collection('stats').doc('gamification').set(
            data,
            SetOptions(merge: true),
          );
          break;
        case 'mark_word_learned':
          await db.collection('users').doc(uid).collection('learnedWords').doc(data['wordId']).set({
            'learnedAt': FieldValue.serverTimestamp(),
          });
          break;
        case 'toggle_favorite':
          final favRef = db.collection('users').doc(uid).collection('favorites').doc(data['wordId']);
          if (data['isAdding'] == true) {
            await favRef.set(data['wordData']);
          } else {
            await favRef.delete();
          }
          break;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}