import 'package:shared_preferences/shared_preferences.dart';

const _prefsSwipedIdsKey = 'paperpulse_swiped_ids';
const _prefsSwipedDateKey = 'paperpulse_swiped_date';

String _todayString() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// Returns the set of paper IDs the user has swiped today.
/// Auto-clears and returns empty when the calendar day has rolled over.
Future<Set<String>> loadSwipedIdsForToday() async {
  final prefs = await SharedPreferences.getInstance();
  final storedDate = prefs.getString(_prefsSwipedDateKey);
  final today = _todayString();
  if (storedDate != today) {
    await prefs.remove(_prefsSwipedIdsKey);
    await prefs.setString(_prefsSwipedDateKey, today);
    return <String>{};
  }
  return (prefs.getStringList(_prefsSwipedIdsKey) ?? const []).toSet();
}

Future<void> recordSwipedId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final today = _todayString();
  final storedDate = prefs.getString(_prefsSwipedDateKey);
  final existing = storedDate == today
      ? (prefs.getStringList(_prefsSwipedIdsKey) ?? const <String>[])
      : const <String>[];
  if (existing.contains(id)) return;
  final updated = [...existing, id];
  await prefs.setStringList(_prefsSwipedIdsKey, updated);
  await prefs.setString(_prefsSwipedDateKey, today);
}
