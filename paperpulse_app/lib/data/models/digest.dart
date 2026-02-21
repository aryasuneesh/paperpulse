class Digest {
  final String id;
  final String userId;
  final DateTime weekOf;
  final List<String> paperIds;
  final DateTime? deliveredAt;
  final DateTime? openedAt;

  Digest({
    required this.id,
    required this.userId,
    required this.weekOf,
    required this.paperIds,
    this.deliveredAt,
    this.openedAt,
  });
}
