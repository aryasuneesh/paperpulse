import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paperpulse_app/data/repositories/paper_repository.dart';

void main() {
  group('PaperRepository.fetchDailyPapers', () {
    test('throws TimeoutException when request takes longer than 15 seconds', () async {
      final slowClient = MockClient((_) async {
        await Future.delayed(const Duration(seconds: 20));
        return http.Response('[]', 200);
      });

      final repo = PaperRepository(client: slowClient);
      expect(
        () => repo.fetchDailyPapers(),
        throwsA(isA<Exception>()),
      );
    });

    test('returns papers on successful response', () async {
      const mockJson = '''
[{
  "paper": {
    "id": "1234.56789",
    "title": "Test Paper",
    "authors": [{"name": "Alice"}],
    "publishedAt": "2026-01-01T00:00:00.000Z",
    "summary": "A test summary."
  }
}]''';
      final successClient = MockClient((_) async => http.Response(mockJson, 200));
      final repo = PaperRepository(client: successClient);

      final papers = await repo.fetchDailyPapers();
      expect(papers.length, equals(1));
      expect(papers.first.title, equals('Test Paper'));
      expect(papers.first.authors, equals(['Alice']));
    });

    test('throws on non-200 status', () async {
      final errorClient = MockClient((_) async => http.Response('error', 500));
      final repo = PaperRepository(client: errorClient);
      expect(() => repo.fetchDailyPapers(), throwsA(isA<Exception>()));
    });
  });

  group('organization parsing', () {
    test('parses top-level organization when present', () async {
      final mockClient = MockClient((req) async {
        return http.Response(jsonEncode([
          {
            'paper': {
              'id': '2604.17849',
              'title': 'T',
              'authors': [{'name': 'A'}],
              'publishedAt': '2026-04-20T00:00:00.000Z',
              'arxiv_categories': ['cs.LG'],
              'summary': 's',
            },
            'organization': {
              '_id': 'o1',
              'name': 'simular-ai',
              'fullname': 'Simular',
              'avatar': 'https://a/b.png',
            },
          }
        ]), 200);
      });
      final repo = PaperRepository(client: mockClient);
      final papers = await repo.fetchDailyPapers();
      expect(papers, hasLength(1));
      expect(papers.first.organization, isNotNull);
      expect(papers.first.organization!.name, 'simular-ai');
      expect(papers.first.organization!.fullname, 'Simular');
    });

    test('tolerates missing organization field', () async {
      final mockClient = MockClient((req) async {
        return http.Response(jsonEncode([
          {
            'paper': {
              'id': '2604.17850',
              'title': 'T',
              'authors': [{'name': 'A'}],
              'publishedAt': '2026-04-20T00:00:00.000Z',
            }
          }
        ]), 200);
      });
      final repo = PaperRepository(client: mockClient);
      final papers = await repo.fetchDailyPapers();
      expect(papers.first.organization, isNull);
    });
  });
}
