enum BookmarkStatus { unread, in_progress, finished }

class Bookmark {
  final String id;
  final String userId;
  final String paperId;
  final DateTime createdAt;
  final BookmarkStatus status;
  final List<String> topicTags;

  Bookmark({
    required this.id,
    required this.userId,
    required this.paperId,
    required this.createdAt,
    this.status = BookmarkStatus.unread,
    this.topicTags = const [],
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      userId: json['userId'] as String,
      paperId: json['paperId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: BookmarkStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => BookmarkStatus.unread,
      ),
      topicTags: List<String>.from(json['topicTags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'paperId': paperId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString(),
      'topicTags': topicTags,
    };
  }
}
