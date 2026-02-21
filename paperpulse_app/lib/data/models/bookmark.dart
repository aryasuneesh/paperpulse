enum BookmarkStatus { unread, in_progress, finished }

class Bookmark {
  final String id;
  final String userId;
  final String paperId;
  final DateTime createdAt;
  final BookmarkStatus status;

  Bookmark({
    required this.id,
    required this.userId,
    required this.paperId,
    required this.createdAt,
    this.status = BookmarkStatus.unread,
  });
}
