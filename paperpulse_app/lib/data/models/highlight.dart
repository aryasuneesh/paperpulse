class Highlight {
  final String id;
  final String userId;
  final String paperId;
  final String textContent;
  final String color; // e.g., hex string
  final DateTime createdAt;

  Highlight({
    required this.id,
    required this.userId,
    required this.paperId,
    required this.textContent,
    required this.color,
    required this.createdAt,
  });
}
