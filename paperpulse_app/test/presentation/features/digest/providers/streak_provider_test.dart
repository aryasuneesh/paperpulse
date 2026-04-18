import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paperpulse_app/presentation/features/digest/providers/streak_provider.dart';

void main() {
  group('StreakNotifier.markActivity', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('returns true and sets streak to 1 on first ever activity', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final result =
          await container.read(streakProvider.notifier).markActivity();
      expect(result, true);
      expect(container.read(streakProvider), 1);
    });

    test('returns false when activity already marked today', () async {
      final today = DateTime.now();
      final todayStr =
          DateTime(today.year, today.month, today.day).toIso8601String();
      SharedPreferences.setMockInitialValues({
        'paperpulse_streak_count': 1,
        'paperpulse_streak_last_date': todayStr,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final result =
          await container.read(streakProvider.notifier).markActivity();
      expect(result, false);
      expect(container.read(streakProvider), 1);
    });

    test('returns true and increments when last activity was yesterday',
        () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      ).toIso8601String();
      SharedPreferences.setMockInitialValues({
        'paperpulse_streak_count': 3,
        'paperpulse_streak_last_date': yesterdayStr,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final result =
          await container.read(streakProvider.notifier).markActivity();
      expect(result, true);
      expect(container.read(streakProvider), 4);
    });

    test('returns true and resets to 1 when streak was broken', () async {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final oldStr = DateTime(
        threeDaysAgo.year,
        threeDaysAgo.month,
        threeDaysAgo.day,
      ).toIso8601String();
      SharedPreferences.setMockInitialValues({
        'paperpulse_streak_count': 5,
        'paperpulse_streak_last_date': oldStr,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final result =
          await container.read(streakProvider.notifier).markActivity();
      expect(result, true);
      expect(container.read(streakProvider), 1);
    });
  });
}
