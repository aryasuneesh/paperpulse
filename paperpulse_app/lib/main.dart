import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/routing/app_router.dart';

void main() {
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
