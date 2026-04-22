import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/paper.dart';
import '../../../../data/providers/papers_provider.dart';
import '../../../../services/digest_personalization_service.dart';
import '../../library/providers/bookmark_provider.dart';

final digestSizeProvider = FutureProvider<int>((ref) async {
  return loadDigestSize();
});

final interestTopicsProvider = FutureProvider<List<String>>((ref) async {
  return loadInterestTopics();
});

final extendedDigestProvider = Provider<AsyncValue<List<Paper>>>((ref) {
  final papersAsync = ref.watch(papersProvider);
  final bookmarks = ref.watch(bookmarkProvider);
  final mainAsync = ref.watch(personalizedDigestProvider);
  final topicsAsync = ref.watch(interestTopicsProvider);

  return papersAsync.when(
    data: (papers) => mainAsync.when(
      data: (main) => topicsAsync.when(
        data: (topics) {
          final signal = topicSignal(
            interestTopics: topics,
            bookmarks: bookmarks,
          );
          final exclude = {
            ...bookmarks.map((b) => b.paperId),
            ...main.map((p) => p.id),
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
  );
});

final personalizedDigestProvider = Provider<AsyncValue<List<Paper>>>((ref) {
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
          final selected = selectPersonalizedPapers(
            papers: available,
            signal: signal,
            size: size,
          );
          return AsyncValue.data(selected);
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
