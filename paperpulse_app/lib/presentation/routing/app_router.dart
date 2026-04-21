import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/browse/browse_screen.dart';
import '../features/digest/digest_screen.dart';
import '../features/library/library_screen.dart';
import '../features/onboarding/account_creation_screen.dart';
import '../features/onboarding/digest_schedule_screen.dart';
import '../features/onboarding/hero_screen.dart';
import '../features/onboarding/interest_picker_screen.dart';
import '../features/onboarding/sample_cards_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/labs/lab_settings_screen.dart';
import '../features/profile/profile_screen.dart';
import 'scaffold_with_nav_bar.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorDigestKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellDigest',
);
final shellNavigatorBrowseKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellBrowse',
);
final shellNavigatorLibraryKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellLibrary',
);
final shellNavigatorProfileKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellProfile',
);

final goRouter = GoRouter(
  initialLocation: '/splash',
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding/welcome',
      builder: (context, state) => const HeroScreen(),
    ),
    GoRoute(
      path: '/onboarding/interests',
      builder: (context, state) => const InterestPickerScreen(),
    ),
    GoRoute(
      path: '/onboarding/schedule',
      builder: (context, state) => const DigestScheduleScreen(),
    ),
    GoRoute(
      path: '/onboarding/preview',
      builder: (context, state) => const SampleCardsScreen(),
    ),
    GoRoute(
      path: '/onboarding/account',
      builder: (context, state) => const AccountCreationScreen(),
    ),
    GoRoute(
      path: '/labs',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LabSettingsScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // The digest branch
        StatefulShellBranch(
          navigatorKey: shellNavigatorDigestKey,
          routes: [
            GoRoute(
              path: '/digest',
              builder: (context, state) => const DigestScreen(),
            ),
          ],
        ),
        // The browse branch
        StatefulShellBranch(
          navigatorKey: shellNavigatorBrowseKey,
          routes: [
            GoRoute(
              path: '/browse',
              builder: (context, state) => const BrowseScreen(),
            ),
          ],
        ),
        // The library branch
        StatefulShellBranch(
          navigatorKey: shellNavigatorLibraryKey,
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        // The profile branch
        StatefulShellBranch(
          navigatorKey: shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
