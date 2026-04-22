import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/paper.dart';
import '../../../../data/providers/papers_provider.dart';
import '../../../../services/digest_personalization_service.dart';
import '../../library/providers/bookmark_provider.dart';

final digestSizeProvider = FutureProvider<int>((ref) async {
  return loadDigestSize();
});

final personalizedDigestProvider = Provider<AsyncValue<List<Paper>>>((ref) {
  final papersAsync = ref.watch(papersProvider);
  final bookmarks = ref.watch(bookmarkProvider);
  final sizeAsync = ref.watch(digestSizeProvider);

  return papersAsync.when(
    data: (papers) => sizeAsync.when(
      data: (size) {
        final signal = topicSignalFromBookmarks(bookmarks);
        final selected = selectPersonalizedPapers(
          papers: papers,
          signal: signal,
          bookmarkCount: bookmarks.length,
          size: size,
        );
        return AsyncValue.data(selected);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
