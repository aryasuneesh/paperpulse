// Web stubs — flutter_local_notifications and workmanager are not available on web.
// All functions are no-ops so the app compiles and runs on web without errors.

const String labDailyTaskName = 'paperpulse_lab_daily_rollup';

Future<void> initNotificationsPlugin() async {}

Future<bool> requestNotificationPermission() async => false;

@pragma('vm:entry-point')
void labBackgroundCallback() {}

Future<void> runLabDailyCheck() async {}

Future<void> ensureDailyTaskRegistered() async {}

Future<void> cancelDailyTask() async {}
