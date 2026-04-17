import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserMigrationService {
  static const _highlightsKey = 'paperpulse_highlights';
  static const _bookmarksKey = 'paperpulse_bookmarks';

  static Future<void> migrateIfNeeded({
    required SharedPreferences prefs,
    required String fromUserId,
    required String toUserId,
  }) async {
    if (fromUserId == toUserId) return;
    _rewriteUserId(prefs, _highlightsKey, fromUserId, toUserId);
    _rewriteUserId(prefs, _bookmarksKey, fromUserId, toUserId);
  }

  static void _rewriteUserId(
    SharedPreferences prefs,
    String key,
    String fromId,
    String toId,
  ) {
    final raw = prefs.getString(key);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final updated = list.map((item) {
        if (item['userId'] == fromId) {
          return {...item, 'userId': toId};
        }
        return item;
      }).toList();
      prefs.setString(key, jsonEncode(updated));
    } catch (_) {
      // Corrupt data — leave as-is rather than wiping
    }
  }
}
