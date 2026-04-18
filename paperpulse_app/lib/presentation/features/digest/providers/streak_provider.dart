import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _streakCountKey = 'paperpulse_streak_count';
const _streakLastDateKey = 'paperpulse_streak_last_date';

final streakProvider = NotifierProvider<StreakNotifier, int>(StreakNotifier.new);

class StreakNotifier extends Notifier<int> {
  @override
  int build() {
    _load();
    return 0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_streakCountKey) ?? 0;
    final lastDateStr = prefs.getString(_streakLastDateKey);

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final today = _today();
      final yesterday = today.subtract(const Duration(days: 1));
      if (lastDate.isBefore(yesterday)) {
        await prefs.setInt(_streakCountKey, 0);
        state = 0;
        return;
      }
    }

    state = count;
  }

  /// Marks activity for today. Returns true if the streak counter incremented
  /// (i.e. this is the first qualifying activity of a new calendar day), false
  /// if the day was already counted.
  Future<bool> markActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final lastDateStr = prefs.getString(_streakLastDateKey);

    if (lastDateStr != null) {
      final parsed = DateTime.parse(lastDateStr);
      final lastDate = DateTime(parsed.year, parsed.month, parsed.day);

      if (lastDate == today) {
        // Already counted today — ensure state reflects persisted count.
        state = prefs.getInt(_streakCountKey) ?? 0;
        return false;
      }

      final yesterday = today.subtract(const Duration(days: 1));
      final currentCount = prefs.getInt(_streakCountKey) ?? 0;
      final newCount = lastDate == yesterday ? currentCount + 1 : 1;

      await prefs.setInt(_streakCountKey, newCount);
      await prefs.setString(_streakLastDateKey, today.toIso8601String());
      state = newCount;
      return true;
    } else {
      // First ever activity
      await prefs.setInt(_streakCountKey, 1);
      await prefs.setString(_streakLastDateKey, today.toIso8601String());
      state = 1;
      return true;
    }
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}
