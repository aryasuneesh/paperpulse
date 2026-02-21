enum PaperSource { arxiv, semantic_scholar, ieee, community }

class Paper {
  final String id;
  final String title;
  final List<String> authors;
  final String? institution;
  final PaperSource source;
  final String sourceUrl;
  final String? doi;
  final DateTime publishedAt;
  final List<String> topicTags;
  final String curiosityHook;
  final int citationCount;
  final String? submittedByUserId; // null if editorial

  Paper({
    required this.id,
    required this.title,
    required this.authors,
    this.institution,
    required this.source,
    required this.sourceUrl,
    this.doi,
    required this.publishedAt,
    required this.topicTags,
    required this.curiosityHook,
    this.citationCount = 0,
    this.submittedByUserId,
  });
}
