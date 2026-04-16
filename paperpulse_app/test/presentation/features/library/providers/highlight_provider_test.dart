import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paperpulse_app/main.dart' show sharedPrefs;
import 'package:paperpulse_app/core/providers/user_provider.dart';
import 'package:paperpulse_app/data/models/highlight.dart';
import 'package:paperpulse_app/presentation/features/library/providers/highlight_provider.dart';

ProviderContainer makeContainer() {
  return ProviderContainer(
    overrides: [currentUserIdProvider.overrideWithValue('test-user')],
  );
}

Highlight makeHighlight({
  String id = 'h1',
  String paperId = 'paper1',
  int? pageNumber = 1,
}) {
  return Highlight(
    id: id,
    userId: 'test-user',
    paperId: paperId,
    textContent: 'Some text',
    color: '#A3B899',
    pageNumber: pageNumber,
    annotationName: id,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  group('HighlightNotifier', () {
    test('starts with empty state', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(highlightProvider), isEmpty);
    });

    test('addHighlight adds to state and persists', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final highlight = makeHighlight();
      container.read(highlightProvider.notifier).addHighlight(highlight);

      expect(container.read(highlightProvider).length, equals(1));
      expect(container.read(highlightProvider).first.id, equals('h1'));

      // Verify persistence: new container reads from shared prefs
      final container2 = makeContainer();
      addTearDown(container2.dispose);
      expect(container2.read(highlightProvider).length, equals(1));
    });

    test('updateHighlight replaces matching entry', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final original = makeHighlight();
      container.read(highlightProvider.notifier).addHighlight(original);

      final updated = original.copyWith(textContent: 'Updated text');
      container.read(highlightProvider.notifier).updateHighlight(updated);

      final state = container.read(highlightProvider);
      expect(state.length, equals(1));
      expect(state.first.textContent, equals('Updated text'));
    });

    test('getHighlightsForPaper filters by paperId', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(highlightProvider.notifier).addHighlight(makeHighlight(id: 'h1', paperId: 'paper1'));
      container.read(highlightProvider.notifier).addHighlight(makeHighlight(id: 'h2', paperId: 'paper2'));
      container.read(highlightProvider.notifier).addHighlight(makeHighlight(id: 'h3', paperId: 'paper1'));

      final paper1Highlights = container.read(highlightProvider.notifier).getHighlightsForPaper('paper1');
      expect(paper1Highlights.length, equals(2));
      expect(paper1Highlights.every((h) => h.paperId == 'paper1'), isTrue);
    });

    test('removeHighlights with highlights that have no local PDF completes without error', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final h = makeHighlight();
      container.read(highlightProvider.notifier).addHighlight(h);

      // removeHighlights tries to open a PDF file that doesn't exist — must not throw
      await expectLater(
        container.read(highlightProvider.notifier).removeHighlights([h]),
        completes,
      );
      expect(container.read(highlightProvider), isEmpty);
    });
  });
}
