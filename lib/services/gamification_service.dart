import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sync_service.dart';

class GamificationService {
  final _db = FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference get _statsRef => _db.collection('users').doc(_uid).collection('stats').doc('gamification');

  Future<Map<String, dynamic>> getStats() async {
    if (_uid == null) return _defaultStats();
    final doc = await _statsRef.get();
    if (!doc.exists) {
      await _statsRef.set(_defaultStats());
      return _defaultStats();
    }
    return doc.data() as Map<String, dynamic>;
  }

  Map<String, dynamic> _defaultStats() {
    return {
      'xp': 0,
      'streak': 0,
      'longestStreak': 0,
      'lastActiveDate': null,
      'totalWordsLearned': 0,
    };
  }

  int getLevel(int xp) => (xp / 100).floor() + 1;
  int getXpForNextLevel(int xp) => ((getLevel(xp)) * 100) - xp;
  double getLevelProgress(int xp) => (xp % 100) / 100;

  Future<Map<String, dynamic>> addXp(int amount) async {
    if (_uid == null) return _defaultStats();

    final stats = await getStats();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    final lastActive = stats['lastActiveDate'] as String?;
    int newStreak = stats['streak'] ?? 0;

    if (lastActive != todayStr) {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

      if (lastActive == yesterdayStr) {
        newStreak = newStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    final newXp = (stats['xp'] ?? 0) + amount;
    final longestStreak = newStreak > (stats['longestStreak'] ?? 0) ? newStreak : stats['longestStreak'];

    final updated = {
      'xp': newXp,
      'streak': newStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': todayStr,
      'totalWordsLearned': stats['totalWordsLearned'] ?? 0,
    };

    try {
      await _statsRef.set(updated);
      await _logDailyActivity(amount);
    } catch (e) {
      await SyncService().queueOrSync('add_xp', updated);
    }

    return updated;
  }

  Future<void> _logDailyActivity(int xpEarned) async {
    if (_uid == null) return;
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final dailyRef = _db.collection('users').doc(_uid).collection('dailyActivity').doc(dateKey);
    final doc = await dailyRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      await dailyRef.set({
        'xp': (data['xp'] ?? 0) + xpEarned,
        'date': dateKey,
      });
    } else {
      await dailyRef.set({
        'xp': xpEarned,
        'date': dateKey,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getLast7DaysActivity() async {
    if (_uid == null) return [];
    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final doc = await _db.collection('users').doc(_uid).collection('dailyActivity').doc(dateKey).get();

      final xp = doc.exists ? (doc.data() as Map<String, dynamic>)['xp'] ?? 0 : 0;
      result.add({
        'day': _dayLabel(day),
        'xp': xp,
      });
    }

    return result;
  }

  Future<Map<DateTime, int>> getAllActivityHistory() async {
    if (_uid == null) return {};
    final snapshot = await _db.collection('users').doc(_uid).collection('dailyActivity').get();

    final Map<DateTime, int> result = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = data['date'] as String?;
      final xp = data['xp'] ?? 0;
      if (dateStr == null) continue;

      final parts = dateStr.split('-');
      if (parts.length != 3) continue;

      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      result[date] = xp;
    }
    return result;
  }

  String _dayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Future<void> incrementWordsLearned() async {
    if (_uid == null) return;
    final stats = await getStats();
    await _statsRef.set({
      ...stats,
      'totalWordsLearned': (stats['totalWordsLearned'] ?? 0) + 1,
    });
  }

  Stream<DocumentSnapshot> statsStream() {
    return _statsRef.snapshots();
  }

  List<String> getUnlockedAchievementIds(Map<String, dynamic> stats) {
    final xp = stats['xp'] ?? 0;
    final streak = stats['longestStreak'] ?? 0;
    final words = stats['totalWordsLearned'] ?? 0;

    final unlockedIds = <String>[];

    if (streak >= 3) unlockedIds.add('streak_3');
    if (streak >= 7) unlockedIds.add('streak_7');
    if (streak >= 30) unlockedIds.add('streak_30');

    if (words >= 10) unlockedIds.add('words_10');
    if (words >= 50) unlockedIds.add('words_50');
    if (words >= 100) unlockedIds.add('words_100');

    if (xp >= 100) unlockedIds.add('xp_100');
    if (xp >= 500) unlockedIds.add('xp_500');
    if (xp >= 1000) unlockedIds.add('xp_1000');

    return unlockedIds;
  }
}