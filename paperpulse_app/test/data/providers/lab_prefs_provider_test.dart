import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperpulse_app/data/providers/lab_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<LabPrefsNotifier> makeNotifier() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(labPrefsProvider.future);
    return container.read(labPrefsProvider.notifier);
  }

  test('defaults to empty prefs (neither displayed nor favourited)', () async {
    final notifier = await makeNotifier();
    expect(notifier.isDisplayed('deepmind'), isFalse);
    expect(notifier.isFavourited('deepmind'), isFalse);
  });

  test('setDisplayed(true) persists', () async {
    final notifier = await makeNotifier();
    await notifier.setDisplayed('deepmind', true);
    expect(notifier.isDisplayed('deepmind'), isTrue);
    expect(notifier.isFavourited('deepmind'), isFalse);
  });

  test('setFavourited(true) implies setDisplayed(true)', () async {
    final notifier = await makeNotifier();
    await notifier.setFavourited('deepmind', true);
    expect(notifier.isDisplayed('deepmind'), isTrue);
    expect(notifier.isFavourited('deepmind'), isTrue);
  });

  test('setDisplayed(false) clears favourited', () async {
    final notifier = await makeNotifier();
    await notifier.setFavourited('deepmind', true);
    await notifier.setDisplayed('deepmind', false);
    expect(notifier.isDisplayed('deepmind'), isFalse);
    expect(notifier.isFavourited('deepmind'), isFalse);
  });

  test('state persists across notifier rebuild', () async {
    final container = ProviderContainer();
    await container.read(labPrefsProvider.future);
    await container
        .read(labPrefsProvider.notifier)
        .setFavourited('anthropic', true);
    container.dispose();

    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    await c2.read(labPrefsProvider.future);
    final n2 = c2.read(labPrefsProvider.notifier);
    expect(n2.isDisplayed('anthropic'), isTrue);
    expect(n2.isFavourited('anthropic'), isTrue);
  });
}
