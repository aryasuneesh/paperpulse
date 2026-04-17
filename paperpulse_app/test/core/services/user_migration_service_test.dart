import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paperpulse_app/core/services/user_migration_service.dart';

void main() {
  const deviceId = 'device-uuid-111';
  const supabaseId = 'supabase-uid-999';
  const highlightsKey = 'paperpulse_highlights';
  const bookmarksKey = 'paperpulse_bookmarks';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('migrates highlight userId from device UUID to Supabase UID', () async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(highlightsKey, jsonEncode([
      {'id': 'h1', 'userId': deviceId, 'paperId': 'p1', 'textContent': 'hello',
       'color': '#FFFF00', 'annotationName': 'ann1', 'tags': [],
       'createdAt': '2026-01-01T00:00:00.000Z'},
    ]));

    await UserMigrationService.migrateIfNeeded(
      prefs: prefs,
      fromUserId: deviceId,
      toUserId: supabaseId,
    );

    final raw = prefs.getString(highlightsKey)!;
    final list = jsonDecode(raw) as List;
    expect(list.first['userId'], equals(supabaseId));
  });

  test('migrates bookmark userId from device UUID to Supabase UID', () async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(bookmarksKey, jsonEncode([
      {'id': 'b1', 'userId': deviceId, 'paperId': 'p1',
       'createdAt': '2026-01-01T00:00:00.000Z',
       'status': 'BookmarkStatus.unread', 'topicTags': []},
    ]));

    await UserMigrationService.migrateIfNeeded(
      prefs: prefs,
      fromUserId: deviceId,
      toUserId: supabaseId,
    );

    final raw = prefs.getString(bookmarksKey)!;
    final list = jsonDecode(raw) as List;
    expect(list.first['userId'], equals(supabaseId));
  });

  test('no-ops when fromUserId == toUserId', () async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(highlightsKey, jsonEncode([
      {'id': 'h1', 'userId': deviceId, 'paperId': 'p1', 'textContent': 'hi',
       'color': '#FFFF00', 'annotationName': 'ann1', 'tags': [],
       'createdAt': '2026-01-01T00:00:00.000Z'},
    ]));

    await UserMigrationService.migrateIfNeeded(
      prefs: prefs,
      fromUserId: deviceId,
      toUserId: deviceId,
    );

    final raw = prefs.getString(highlightsKey)!;
    final list = jsonDecode(raw) as List;
    expect(list.first['userId'], equals(deviceId));
  });

  test('handles missing prefs keys gracefully', () async {
    final prefs = await SharedPreferences.getInstance();
    // no highlights or bookmarks keys set
    await expectLater(
      UserMigrationService.migrateIfNeeded(
        prefs: prefs,
        fromUserId: deviceId,
        toUserId: supabaseId,
      ),
      completes,
    );
  });
}
