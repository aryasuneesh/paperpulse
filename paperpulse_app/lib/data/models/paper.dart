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
  final String? submittedByUserId;

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'authors': authors,
    'institution': institution,
    'source': source.name,
    'sourceUrl': sourceUrl,
    'doi': doi,
    'publishedAt': publishedAt.toIso8601String(),
    'topicTags': topicTags,
    'curiosityHook': curiosityHook,
    'citationCount': citationCount,
    'submittedByUserId': submittedByUserId,
  };

  factory Paper.fromJson(Map<String, dynamic> json) => Paper(
    id: json['id'] as String,
    title: json['title'] as String,
    authors: List<String>.from(json['authors'] as List),
    institution: json['institution'] as String?,
    source: PaperSource.values.firstWhere(
      (e) => e.name == json['source'],
      orElse: () => PaperSource.arxiv,
    ),
    sourceUrl: json['sourceUrl'] as String,
    doi: json['doi'] as String?,
    publishedAt: DateTime.parse(json['publishedAt'] as String),
    topicTags: List<String>.from(json['topicTags'] as List),
    curiosityHook: json['curiosityHook'] as String,
    citationCount: (json['citationCount'] as num?)?.toInt() ?? 0,
    submittedByUserId: json['submittedByUserId'] as String?,
  );
}
