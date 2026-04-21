import 'paper.dart';

enum BookmarkStatus { unread, in_progress, finished }

class Bookmark {
  final String id;
  final String userId;
  final String paperId;
  final DateTime createdAt;
  final BookmarkStatus status;
  final List<String> topicTags;
  final Paper paper;

  Bookmark({
    required this.id,
    required this.userId,
    required this.paperId,
    required this.createdAt,
    required this.paper,
    this.status = BookmarkStatus.unread,
    this.topicTags = const [],
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    final paperJson = json['paper'];
    if (paperJson is! Map<String, dynamic>) {
      // Legacy bookmarks saved before we embedded the Paper snapshot. Drop
      // them by throwing — the loader filters exceptions out.
      throw const FormatException('Bookmark missing embedded paper snapshot');
    }
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
      paper: Paper.fromJson(paperJson),
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
      'paper': paper.toJson(),
    };
  }
}
