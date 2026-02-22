import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'presentation/routing/app_router.dart';

late final SharedPreferences sharedPrefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: 'https://dcalxffrersyylthiuon.supabase.co',
    anonKey: 'sb_publishable_6HQX_VIUhAYZzNPhNvTOBg_e-3Q324X',
  );

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
      themeMode: ThemeMode.system, // Support system theme toggle later
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
