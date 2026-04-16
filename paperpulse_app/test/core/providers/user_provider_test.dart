import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paperpulse_app/main.dart' show sharedPrefs;
import 'package:paperpulse_app/core/providers/user_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  group('currentUserIdProvider', () {
    test('returns a non-empty stable ID when no Supabase user is logged in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final id1 = container.read(currentUserIdProvider);
      expect(id1, isNotEmpty);

      // A second container (simulating app restart) reads same stored value
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      final id2 = container2.read(currentUserIdProvider);

      expect(id1, equals(id2));
    });

    test('stored device UUID matches UUID v4 pattern', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final id = container.read(currentUserIdProvider);
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(uuidPattern.hasMatch(id), isTrue, reason: 'Expected UUID v4, got: $id');
    });

    test('can be overridden in tests', () {
      final container = ProviderContainer(
        overrides: [currentUserIdProvider.overrideWithValue('test-user-42')],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUserIdProvider), equals('test-user-42'));
    });
  });
}
