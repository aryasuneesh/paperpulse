import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'digest_notification_service.dart' show digestTaskName, runDigestNotification;
import 'daily_paper_notification_service.dart'
    show dailyPaperTaskName, runDailyPaperRollup;
import '../data/models/lab_pref.dart';
import '../data/models/paper.dart';
import '../data/providers/lab_catalog_provider.dart';
import '../data/repositories/lab_catalog_repository.dart';
import '../data/repositories/paper_repository.dart';

const String labDailyTaskName = 'paperpulse_lab_daily_rollup';
const String _lastSeenKey = 'lab_notifications_last_seen_v1';
const int _lastSeenMaxSize = 500; // cap ~30 days * daily volume

const _androidChannelId = 'paperpulse_labs';
const _androidChannelName = 'Favourite labs';
const _androidChannelDesc = 'Daily rollup of new papers from favourite labs';

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotificationsPlugin() async {
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
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDesc,
      importance: Importance.defaultImportance,
    ),
  );
}

/// Request OS permission for notifications. Returns true if granted.
Future<bool> requestNotificationPermission() async {
  final androidImpl = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  final iosImpl = _plugin.resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>();
  final android = await androidImpl?.requestNotificationsPermission();
  final ios = await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  return (android ?? true) && (ios ?? true);
}

/// Top-level workmanager entry point. Must be a top-level or static function.
@pragma('vm:entry-point')
void labBackgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await initNotificationsPlugin();
      if (task == labDailyTaskName) {
        await runLabDailyCheck();
      } else if (task == digestTaskName) {
        await runDigestNotification();
      } else if (task == dailyPaperTaskName) {
        await runDailyPaperRollup();
      }
    } catch (_) {
      // Swallow — don't trigger WorkManager backoff on transient errors.
    }
    return true;
  });
}

/// Fetch, diff, and emit a rollup notification if there are new papers from
/// favourited labs. Exposed for manual triggering (e.g., debug button).
Future<void> runLabDailyCheck() async {
  final prefs = await SharedPreferences.getInstance();

  final prefsRaw = prefs.getString('lab_prefs_v1');
  if (prefsRaw == null) return;
  final prefsMap = (jsonDecode(prefsRaw) as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, LabPref.fromJson(v as Map<String, dynamic>)),
  );
  final favouritedIds =
      prefsMap.entries.where((e) => e.value.favourited).map((e) => e.key).toSet();
  if (favouritedIds.isEmpty) return;

  final labs = await LabCatalogRepository().load();
  final labById = {for (final l in labs) l.id: l};

  final papers = await PaperRepository().fetchDailyPapers();

  final favouritedPapers = <Paper>[];
  for (final p in papers) {
    final id = resolveLabId(p.organization, labs);
    if (id != null && favouritedIds.contains(id)) {
      favouritedPapers.add(p);
    }
  }
  if (favouritedPapers.isEmpty) return;

  final lastSeen = (prefs.getStringList(_lastSeenKey) ?? const <String>[]).toSet();
  final newPapers =
      favouritedPapers.where((p) => !lastSeen.contains(p.id)).toList();
  if (newPapers.isEmpty) return;

  final byLab = <String, int>{};
  for (final p in newPapers) {
    final id = resolveLabId(p.organization, labs)!;
    byLab[id] = (byLab[id] ?? 0) + 1;
  }
  final bodyParts = byLab.entries.map((e) {
    final name = labById[e.key]?.displayName ?? e.key;
    return '$name (${e.value})';
  }).toList();

  final title =
      '${newPapers.length} new paper${newPapers.length == 1 ? '' : 's'} '
      'from your favourite labs';
  final body = bodyParts.join(', ');

  await _plugin.show(
    0,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: 'labs_rollup',
  );

  final updated = {...lastSeen, ...newPapers.map((p) => p.id)}.toList();
  final capped = updated.length > _lastSeenMaxSize
      ? updated.sublist(updated.length - _lastSeenMaxSize)
      : updated;
  await prefs.setStringList(_lastSeenKey, capped);
}

Future<void> ensureDailyTaskRegistered() async {
  await Workmanager().registerPeriodicTask(
    labDailyTaskName,
    labDailyTaskName,
    frequency: const Duration(hours: 24),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

Future<void> cancelDailyTask() async {
  await Workmanager().cancelByUniqueName(labDailyTaskName);
}
