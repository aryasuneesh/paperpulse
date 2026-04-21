import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper.dart';
import '../models/paper_organization.dart';

final paperRepositoryProvider = Provider((ref) => PaperRepository());

class PaperRepository {
  static const String _baseUrl = 'https://huggingface.co/api/daily_papers';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  PaperRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Paper>> fetchDailyPapers() async {
    final response = await _client.get(Uri.parse(_baseUrl)).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load daily papers (${response.statusCode})');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((entry) => _parsePaper(entry)).whereType<Paper>().toList();
  }

  Paper? _parsePaper(dynamic entry) {
    try {
      final paperNode = entry['paper'] as Map<String, dynamic>;
      final id = paperNode['id'] as String? ?? '';
      if (id.isEmpty) return null;

      final List<String> authors = paperNode['authors'] != null
          ? (paperNode['authors'] as List)
              .map((a) => a['name'].toString())
              .toList()
          : [];

      final publishedAt = _parseDate(
        paperNode['publishedAt'] as String? ??
            paperNode['submittedOnDailyAt'] as String? ??
            DateTime.now().toIso8601String(),
      );

      final title = paperNode['title'] as String? ?? 'Unknown Title';
      final summary = paperNode['summary'] as String? ?? '';

      // Try arxiv_categories first; fall back to keyword inference
      List<String> topics = [];
      final rawCategories = paperNode['arxiv_categories'];
      if (rawCategories is List && rawCategories.isNotEmpty) {
        topics = rawCategories
            .map((c) => _categoryToLabel(c.toString()))
            .toSet()
            .take(2)
            .toList();
      }
      if (topics.isEmpty) {
        topics = _inferTopics(title, summary);
      }

      PaperOrganization? organization;
      final orgNode = entry['organization'];
      if (orgNode is Map<String, dynamic>) {
        organization = PaperOrganization.fromJson(orgNode);
      }

      return Paper(
        id: id,
        title: title,
        authors: authors,
        source: PaperSource.arxiv,
        sourceUrl: 'https://arxiv.org/pdf/$id.pdf',
        publishedAt: publishedAt,
        topicTags: topics,
        curiosityHook: summary.isNotEmpty ? summary : 'No summary available.',
        citationCount: 0,
        organization: organization,
      );
    } catch (_) {
      return null;
    }
  }

  DateTime _parseDate(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.now();
    }
  }

  // Maps arXiv category codes to human-readable labels
  static String _categoryToLabel(String category) {
    switch (category) {
      case 'cs.LG':
        return 'Machine Learning';
      case 'cs.AI':
        return 'Artificial Intelligence';
      case 'cs.CV':
        return 'Computer Vision';
      case 'cs.CL':
        return 'Language Models';
      case 'cs.RO':
        return 'Robotics';
      case 'cs.NE':
        return 'Neural Networks';
      case 'cs.IR':
        return 'Information Retrieval';
      case 'cs.HC':
        return 'Human-Computer Interaction';
      case 'cs.CR':
        return 'AI Security';
      case 'eess.IV':
        return 'Image Processing';
      case 'eess.AS':
        return 'Audio & Speech';
      case 'stat.ML':
        return 'Machine Learning';
      default:
        if (category.startsWith('cs.')) return 'Computer Science';
        if (category.startsWith('stat.')) return 'Statistics & ML';
        if (category.startsWith('math.')) return 'Mathematics';
        return 'AI Research';
    }
  }

  // Keyword-based topic inference — used when arxiv_categories is absent
  static List<String> _inferTopics(String title, String summary) {
    final text = '${title.toLowerCase()} ${summary.toLowerCase()}';
    final topics = <String>{};

    if (RegExp(r'\bvision\b|\bimage\b|\bvisual\b|\bsegment\b|\bdetect\b|\bobject\b|\bpixel\b').hasMatch(text)) {
      topics.add('Computer Vision');
    }
    if (RegExp(r'\blanguage model\b|\bllm\b|\btransformer\b|\bgpt\b|\bbert\b|\bllama\b|\btext generation\b|\bnlp\b').hasMatch(text)) {
      topics.add('Language Models');
    }
    if (RegExp(r'\bdiffusion\b|\bgenerative\b|\bgan\b|\bimage synthesis\b|\btext.to.image\b').hasMatch(text)) {
      topics.add('Generative AI');
    }
    if (RegExp(r'\brobot\b|\bmanipulat\b|\blocomotion\b|\bnavigat\b|\bembodied\b').hasMatch(text)) {
      topics.add('Robotics');
    }
    if (RegExp(r'\breinforcement\b|\breward\b|\bpolicy gradient\b|\brl\b|\bq.learning\b').hasMatch(text)) {
      topics.add('Reinforcement Learning');
    }
    if (RegExp(r'\baudio\b|\bspeech\b|\bvoice\b|\bacoustic\b|\bwav\b|\basr\b').hasMatch(text)) {
      topics.add('Audio & Speech');
    }
    if (RegExp(r'\bsafety\b|\balignment\b|\bharmful\b|\bbias\b|\bfairness\b|\bjailbreak\b').hasMatch(text)) {
      topics.add('AI Safety');
    }
    if (RegExp(r'\bmultimodal\b|\bmulti.modal\b|\bcross.modal\b|\bvideo\b|\baudio.visual\b').hasMatch(text)) {
      topics.add('Multimodal AI');
    }
    if (RegExp(r'\bgraph\b|\bknowledge graph\b|\bgnn\b|\bgraph neural\b').hasMatch(text)) {
      topics.add('Graph Learning');
    }

    if (topics.isEmpty) topics.add('Machine Learning');
    return topics.take(2).toList();
  }
}
