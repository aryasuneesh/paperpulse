import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/paper.dart';
import '../../../../data/providers/papers_provider.dart';
import '../../../../services/digest_personalization_service.dart';
import '../../../../services/digest_swipe_history_service.dart';
import '../../library/providers/bookmark_provider.dart';

final digestSizeProvider = FutureProvider<int>((ref) async {
  return loadDigestSize();
});

final interestTopicsProvider = FutureProvider<List<String>>((ref) async {
  return loadInterestTopics();
});

class SwipedIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    return loadSwipedIdsForToday();
  }

  Future<void> record(String id) async {
    await recordSwipedId(id);
    final current = state.asData?.value ?? <String>{};
    state = AsyncValue.data({...current, id});
  }
}

final swipedIdsProvider =
    AsyncNotifierProvider<SwipedIdsNotifier, Set<String>>(
      SwipedIdsNotifier.new,
    );

final extendedDigestProvider = Provider<AsyncValue<List<Paper>>>((ref) {
  final papersAsync = ref.watch(papersProvider);
  final bookmarks = ref.watch(bookmarkProvider);
  final mainAsync = ref.watch(_mainDigestFullProvider);
  final topicsAsync = ref.watch(interestTopicsProvider);
  final swipedAsync = ref.watch(swipedIdsProvider);

  return papersAsync.when(
    data: (papers) => mainAsync.when(
      data: (main) => topicsAsync.when(
        data: (topics) => swipedAsync.when(
          data: (swiped) {
            final signal = topicSignal(
              interestTopics: topics,
              bookmarks: bookmarks,
            );
            final exclude = {
              ...bookmarks.map((b) => b.paperId),
              ...main.map((p) => p.id),
              ...swiped,
            };
            final extended = selectExtendedPapers(
              papers: papers,
              signal: signal,
              excludeIds: exclude,
            );
            return AsyncValue.data(extended);
          },
          loading: () => const AsyncValue.loading(),
          error: (e, st) => AsyncValue.error(e, st),
        ),
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Top-N personalized selection *before* swipe-filtering. Used by
/// [extendedDigestProvider] to know which papers are considered "main" and
/// should be excluded from the extended pool even after the user swipes them.
final _mainDigestFullProvider = Provider<AsyncValue<List<Paper>>>((ref) {
  final papersAsync = ref.watch(papersProvider);
  final bookmarks = ref.watch(bookmarkProvider);
  final sizeAsync = ref.watch(digestSizeProvider);
  final topicsAsync = ref.watch(interestTopicsProvider);

  return papersAsync.when(
    data: (papers) => sizeAsync.when(
      data: (size) => topicsAsync.when(
        data: (topics) {
          final bookmarkedIds = bookmarks.map((b) => b.paperId).toSet();
          final available =
              papers.where((p) => !bookmarkedIds.contains(p.id)).toList();
          final signal = topicSignal(
            interestTopics: topics,
            bookmarks: bookmarks,
          );
          return AsyncValue.data(selectPersonalizedPapers(
            papers: available,
            signal: signal,
            size: size,
          ));
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

final personalizedDigestProvider = Provider<AsyncValue<List<Paper>>>((ref) {
  final mainAsync = ref.watch(_mainDigestFullProvider);
  final swipedAsync = ref.watch(swipedIdsProvider);

  return mainAsync.when(
    data: (main) => swipedAsync.when(
      data: (swiped) =>
          AsyncValue.data(main.where((p) => !swiped.contains(p.id)).toList()),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
