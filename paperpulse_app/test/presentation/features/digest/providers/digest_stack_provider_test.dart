import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperpulse_app/data/models/paper.dart';
import 'package:paperpulse_app/data/repositories/paper_repository.dart';
import 'package:paperpulse_app/presentation/features/digest/providers/digest_stack_provider.dart';

class FakePaperRepository extends PaperRepository {
  final Future<List<Paper>> Function() _fetch;
  FakePaperRepository(this._fetch);

  @override
  Future<List<Paper>> fetchDailyPapers() => _fetch();
}

void main() {
  group('DigestStackNotifier', () {
    test('starts in loading state', () {
      final container = ProviderContainer(
        overrides: [
          paperRepositoryProvider.overrideWithValue(
            FakePaperRepository(() async => []),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(digestStackProvider);
      expect(state.isLoading, isTrue);
      expect(state.papers, isEmpty);
    });

    test('does not throw StateError when disposed before papers load', () async {
      final completer = Future<List<Paper>>.delayed(
        const Duration(milliseconds: 100),
        () => [],
      );
      final container = ProviderContainer(
        overrides: [
          paperRepositoryProvider.overrideWithValue(
            FakePaperRepository(() => completer),
          ),
        ],
      );

      // Read to initialize, then immediately dispose before fetch completes
      container.read(digestStackProvider);
      container.dispose(); // Must not throw StateError after 100ms

      await Future.delayed(const Duration(milliseconds: 200));
      // If we reach here without an unhandled exception, the guard works
    });

    test('swipeCard increments currentIndex', () async {
      final container = ProviderContainer(
        overrides: [
          paperRepositoryProvider.overrideWithValue(
            FakePaperRepository(() async => [
              Paper(
                id: '1', title: 'P1', authors: [],
                source: PaperSource.community,
                sourceUrl: '', publishedAt: DateTime(2026),
                topicTags: [], curiosityHook: '',
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Initialize provider and pump microtasks so _loadPapers() async completes
      container.read(digestStackProvider);
      await Future<void>.value(); // yield to microtask queue
      await Future<void>.value(); // second pump for any chained futures

      container.read(digestStackProvider.notifier).swipeCard();
      expect(container.read(digestStackProvider).currentIndex, equals(1));
    });
  });
}
