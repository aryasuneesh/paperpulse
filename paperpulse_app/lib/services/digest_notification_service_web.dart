// Web stubs — flutter_local_notifications and workmanager are not available on web.
// All functions are no-ops so the app compiles and runs on web without errors.

import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user.dart';

const String digestTaskName = 'paperpulse_digest_weekly';

Future<void> saveAndScheduleDigest(DigestDay day, DigestTime time) async {}

Future<(DigestDay, DigestTime)?> loadDigestSchedule() async {
  final prefs = await SharedPreferences.getInstance();
  final dayStr = prefs.getString('paperpulse_digest_day');
  final timeStr = prefs.getString('paperpulse_digest_time');
  if (dayStr == null || timeStr == null) return null;
  final day = DigestDay.values.firstWhere((d) => d.name == dayStr,
      orElse: () => DigestDay.mon);
  final time = DigestTime.values.firstWhere((t) => t.name == timeStr,
      orElse: () => DigestTime.morning);
  return (day, time);
}

Future<void> cancelDigestTask() async {}

Future<void> runDigestNotification() async {}
