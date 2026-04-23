import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Deletes every piece of user data PaperPulse stores on the device.
///
/// In the beta, PaperPulse has no cloud account — all user data lives in
/// SharedPreferences (bookmarks, highlights, reading history, topic
/// selections, schedules, caches) and in scheduled WorkManager tasks.
/// This service clears all of the above, satisfying the Play Store
/// account-deletion requirement (2024+).
///
/// After this runs, the next app launch sees a pristine install and will
/// send the user back through onboarding with a fresh device UUID.
class AccountDeletionService {
  AccountDeletionService._();

  /// Wipe all user data. Idempotent — safe to call even if nothing exists.
  static Future<void> deleteEverything() async {
    // 1. Cancel any scheduled background work (digest, daily, lab notifs).
    try {
      await Workmanager().cancelAll();
    } catch (_) {
      // Workmanager may not be initialised in all contexts; ignore.
    }

    // 2. Cancel any pending / active local notifications.
    try {
      await FlutterLocalNotificationsPlugin().cancelAll();
    } catch (_) {
      // Ignore — plugin may not have been initialised.
    }

    // 3. Wipe every SharedPreferences key.
    //    This covers: device UUID, onboarding flag, bookmarks, highlights,
    //    interests, digest schedule, digest size, daily-enabled flag,
    //    swipe history, paper caches, lab prefs, lab caches, last-seen
    //    lists, topic catalog, and anything else we forgot.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
