import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/platform_init.dart';
import 'presentation/routing/app_router.dart';
import 'services/lab_notification_service.dart';

late SharedPreferences sharedPrefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sharedPrefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  await initNotificationsPlugin();
  await initPlatformDeps(labBackgroundCallback);

  runApp(const ProviderScope(child: PaperPulseApp()));
}

class PaperPulseApp extends ConsumerWidget {
  const PaperPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PaperPulse',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
