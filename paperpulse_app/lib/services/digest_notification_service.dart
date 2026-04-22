import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../data/models/user.dart';

const String digestTaskName = 'paperpulse_digest_weekly';
const _digestChannelId = 'paperpulse_digest';
const _digestChannelName = 'Weekly Digest';
const _digestChannelDesc = 'Notification when your weekly paper digest is ready';
const _prefsDayKey = 'paperpulse_digest_day';
const _prefsTimeKey = 'paperpulse_digest_time';

final _digestPlugin = FlutterLocalNotificationsPlugin();

/// Save digest schedule to SharedPreferences and schedule the WorkManager task.
Future<void> saveAndScheduleDigest(DigestDay day, DigestTime time) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefsDayKey, day.name);
  await prefs.setString(_prefsTimeKey, time.name);
  await _scheduleDigestTask(day, time);
}

/// Load saved digest schedule. Returns null if never set.
Future<(DigestDay, DigestTime)?> loadDigestSchedule() async {
  final prefs = await SharedPreferences.getInstance();
  final dayStr = prefs.getString(_prefsDayKey);
  final timeStr = prefs.getString(_prefsTimeKey);
  if (dayStr == null || timeStr == null) return null;
  final day = DigestDay.values.firstWhere((d) => d.name == dayStr,
      orElse: () => DigestDay.mon);
  final time = DigestTime.values.firstWhere((t) => t.name == timeStr,
      orElse: () => DigestTime.morning);
  return (day, time);
}

Future<void> _scheduleDigestTask(DigestDay day, DigestTime time) async {
  await Workmanager().cancelByUniqueName(digestTaskName);
  await Workmanager().registerPeriodicTask(
    digestTaskName,
    digestTaskName,
    frequency: const Duration(days: 7),
    initialDelay: _computeInitialDelay(day, time),
    constraints: Constraints(networkType: NetworkType.not_required),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}

Duration _computeInitialDelay(DigestDay day, DigestTime time) {
  final now = DateTime.now();
  final targetHour = time == DigestTime.morning ? 8 : 19;
  final targetWeekday = switch (day) {
    DigestDay.mon => DateTime.monday,
    DigestDay.wed => DateTime.wednesday,
    DigestDay.fri => DateTime.friday,
  };

  var candidate = DateTime(now.year, now.month, now.day, targetHour);
  int daysUntil = (targetWeekday - now.weekday) % 7;
  if (daysUntil == 0 && !now.isBefore(candidate)) daysUntil = 7;
  candidate = candidate.add(Duration(days: daysUntil));

  return candidate.difference(now);
}

Future<void> cancelDigestTask() async {
  await Workmanager().cancelByUniqueName(digestTaskName);
}

/// Called from the background isolate when the digest task fires.
Future<void> runDigestNotification() async {
  await _ensureDigestChannel();
  await _digestPlugin.show(
    1,
    'Your digest is ready 📬',
    "This week's curated papers are waiting for you.",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _digestChannelId,
        _digestChannelName,
        channelDescription: _digestChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: 'digest',
  );
}

Future<void> _ensureDigestChannel() async {
  const init = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );
  await _digestPlugin.initialize(init);
  final androidImpl = _digestPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidImpl?.createNotificationChannel(
    const AndroidNotificationChannel(
      _digestChannelId,
      _digestChannelName,
      description: _digestChannelDesc,
      importance: Importance.high,
    ),
  );
}
