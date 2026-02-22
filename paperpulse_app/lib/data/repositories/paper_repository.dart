import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper.dart';

final paperRepositoryProvider = Provider((ref) => PaperRepository());

class PaperRepository {
  static const String _baseUrl = 'https://huggingface.co/api/daily_papers';

  Future<List<Paper>> fetchDailyPapers() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((json) {
          final paperNode = json['paper'];

          List<String> authorsList = [];
          if (paperNode['authors'] != null) {
            authorsList = (paperNode['authors'] as List)
                .map((a) => a['name'].toString())
                .toList();
          }

          return Paper(
            id:
                paperNode['id'] ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: paperNode['title'] ?? 'Unknown Title',
            authors: authorsList,
            source: PaperSource.community, // Representing HF Community
            sourceUrl: 'https://arxiv.org/pdf/${paperNode['id']}.pdf',
            publishedAt: DateTime.parse(
              paperNode['publishedAt'] ?? DateTime.now().toIso8601String(),
            ),
            topicTags: [
              'AI',
              'Machine Learning',
            ], // Default tags as HF API doesn't strictly provide these
            curiosityHook: paperNode['summary'] ?? 'No summary available.',
          );
        }).toList();
      } else {
        throw Exception('Failed to load daily papers');
      }
    } catch (e) {
      throw Exception('Error fetching papers: $e');
    }
  }
}
