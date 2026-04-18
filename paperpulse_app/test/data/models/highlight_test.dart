import 'package:flutter_test/flutter_test.dart';
import 'package:paperpulse_app/data/models/highlight.dart';

void main() {
  group('Highlight', () {
    final baseJson = {
      'id': 'h1',
      'userId': 'u1',
      'paperId': 'p1',
      'textContent': 'some text',
      'color': '#A3B899',
      'annotationName': 'ann1',
      'tags': <String>[],
      'createdAt': '2026-04-18T00:00:00.000Z',
    };

    test('fromJson defaults readerType to pdf when field absent', () {
      final h = Highlight.fromJson(baseJson);
      expect(h.readerType, 'pdf');
      expect(h.searchText, isNull);
    });

    test('fromJson reads html readerType and searchText', () {
      final json = {
        ...baseJson,
        'readerType': 'html',
        'searchText': 'the full surrounding sentence',
      };
      final h = Highlight.fromJson(json);
      expect(h.readerType, 'html');
      expect(h.searchText, 'the full surrounding sentence');
    });

    test('toJson includes readerType and searchText', () {
      final h = Highlight(
        id: 'h1',
        userId: 'u1',
        paperId: 'p1',
        textContent: 'text',
        color: '#A3B899',
        annotationName: 'ann1',
        createdAt: DateTime.parse('2026-04-18'),
        readerType: 'html',
        searchText: 'sentence',
      );
      final json = h.toJson();
      expect(json['readerType'], 'html');
      expect(json['searchText'], 'sentence');
    });

    test('toJson includes readerType pdf and null searchText by default', () {
      final h = Highlight(
        id: 'h1',
        userId: 'u1',
        paperId: 'p1',
        textContent: 'text',
        color: '#A3B899',
        annotationName: 'ann1',
        createdAt: DateTime.parse('2026-04-18'),
      );
      final json = h.toJson();
      expect(json['readerType'], 'pdf');
      expect(json['searchText'], isNull);
    });

    test('copyWith preserves readerType and searchText when not overridden', () {
      final original = Highlight(
        id: 'h1',
        userId: 'u1',
        paperId: 'p1',
        textContent: 'text',
        color: '#A3B899',
        annotationName: 'ann1',
        createdAt: DateTime.parse('2026-04-18'),
        readerType: 'html',
        searchText: 'sentence',
      );
      final copy = original.copyWith(textContent: 'new text');
      expect(copy.readerType, 'html');
      expect(copy.searchText, 'sentence');
    });
  });
}
