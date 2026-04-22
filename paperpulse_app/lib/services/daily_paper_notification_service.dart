import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../data/models/bookmark.dart';
import '../data/repositories/paper_repository.dart';
import 'digest_personalization_service.dart';

const String dailyPaperTaskName = 'paperpulse_daily_papers';
const _channelId = 'paperpulse_daily';
const _channelName = 'Daily Papers';
const _channelDesc = 'Daily rollup of new papers matching your interests';
const _lastSeenKey = 'daily_papers_last_seen_v1';
const int _lastSeenMaxSize = 500;

final _plugin = FlutterLocalNotificationsPlugin();

Future<void> ensureDailyPaperTaskRegistered() async {
  await Workmanager().registerPeriodicTask(
    dailyPaperTaskName,
    dailyPaperTaskName,
    frequency: const Duration(hours: 24),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

Future<void> cancelDailyPaperTask() async {
  await Workmanager().cancelByUniqueName(dailyPaperTaskName);
}

Future<void> runDailyPaperRollup() async {
  await _ensureChannel();
  final prefs = await SharedPreferences.getInstance();

  final bookmarksRaw = prefs.getString('paperpulse_bookmarks');
  if (bookmarksRaw == null) return;
  final bookmarks = (jsonDecode(bookmarksRaw) as List)
      .whereType<Map<String, dynamic>>()
      .map((e) {
        try {
          return Bookmark.fromJson(e);
        } catch (_) {
          return null;
        }
      })
      .whereType<Bookmark>()
      .toList();
  if (!hasEnoughTopicSignal(bookmarks.length)) return;

  final papers = await PaperRepository().fetchDailyPapers();
  if (papers.isEmpty) return;

  final lastSeen = (prefs.getStringList(_lastSeenKey) ?? const <String>[]).toSet();
  final newPapers = papers.where((p) => !lastSeen.contains(p.id)).toList();
  if (newPapers.isEmpty) return;

  final signal = topicSignalFromBookmarks(bookmarks);
  final matching = newPapers.where((p) {
    for (final tag in p.topicTags) {
      if (signal.containsKey(tag)) return true;
    }
    return false;
  }).toList();
  if (matching.isEmpty) return;

  final title = '${matching.length} new paper'
      '${matching.length == 1 ? '' : 's'} match your interests';
  final body = matching.take(3).map((p) => p.title).join(' · ');

  await _plugin.show(
    2,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: 'daily_papers',
  );

  final updated = {...lastSeen, ...papers.map((p) => p.id)}.toList();
  final capped = updated.length > _lastSeenMaxSize
      ? updated.sublist(updated.length - _lastSeenMaxSize)
      : updated;
  await prefs.setStringList(_lastSeenKey, capped);
}

Future<void> _ensureChannel() async {
  const init = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );
  await _plugin.initialize(init);
  final androidImpl = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidImpl?.createNotificationChannel(
    const AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.defaultImportance,
    ),
  );
}
