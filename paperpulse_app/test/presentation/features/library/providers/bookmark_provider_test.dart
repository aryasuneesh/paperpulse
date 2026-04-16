import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paperpulse_app/main.dart' show sharedPrefs;
import 'package:paperpulse_app/core/providers/user_provider.dart';
import 'package:paperpulse_app/data/models/bookmark.dart';
import 'package:paperpulse_app/data/models/paper.dart';
import 'package:paperpulse_app/presentation/features/library/providers/bookmark_provider.dart';

Paper makePaper({String id = 'paper1'}) => Paper(
  id: id,
  title: 'Test Paper',
  authors: ['Author A'],
  source: PaperSource.community,
  sourceUrl: 'https://arxiv.org/pdf/$id.pdf',
  publishedAt: DateTime(2026, 1, 1),
  topicTags: ['AI'],
  curiosityHook: 'Interesting.',
);

ProviderContainer makeContainer() {
  return ProviderContainer(
    overrides: [currentUserIdProvider.overrideWithValue('test-user')],
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  group('BookmarkNotifier', () {
    test('starts empty', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(bookmarkProvider), isEmpty);
    });

    test('toggleBookmark adds then removes', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final paper = makePaper();

      container.read(bookmarkProvider.notifier).toggleBookmark(paper);
      expect(container.read(bookmarkProvider).length, equals(1));
      expect(container.read(bookmarkProvider.notifier).isBookmarked(paper.id), isTrue);

      container.read(bookmarkProvider.notifier).toggleBookmark(paper);
      expect(container.read(bookmarkProvider), isEmpty);
      expect(container.read(bookmarkProvider.notifier).isBookmarked(paper.id), isFalse);
    });

    test('new bookmark uses currentUserIdProvider, not user123', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(bookmarkProvider.notifier).toggleBookmark(makePaper());
      final bookmark = container.read(bookmarkProvider).first;
      expect(bookmark.userId, equals('test-user'));
      expect(bookmark.userId, isNot(equals('user123')));
    });

    test('markAsInProgress creates bookmark with in_progress status', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(bookmarkProvider.notifier).markAsInProgress(makePaper());
      final bookmarks = container.read(bookmarkProvider);
      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.status, equals(BookmarkStatus.in_progress));
    });

    test('getBookmarkedPaperIds filters by status', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(bookmarkProvider.notifier);

      notifier.toggleBookmark(makePaper(id: 'paper1'));
      notifier.markAsInProgress(makePaper(id: 'paper2'));

      final unread = notifier.getBookmarkedPaperIds(BookmarkStatus.unread);
      expect(unread, contains('paper1'));
      expect(unread, isNot(contains('paper2')));
    });

    test('persists across container instances', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(bookmarkProvider.notifier).toggleBookmark(makePaper());

      final container2 = makeContainer();
      addTearDown(container2.dispose);
      expect(container2.read(bookmarkProvider).length, equals(1));
    });
  });
}
