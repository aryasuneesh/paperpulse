class PaperOrganization {
  final String id;
  final String name;
  final String fullname;
  final String? avatarUrl;

  const PaperOrganization({
    required this.id,
    required this.name,
    required this.fullname,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fullname': fullname,
        'avatarUrl': avatarUrl,
      };

  factory PaperOrganization.fromJson(Map<String, dynamic> json) =>
      PaperOrganization(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        fullname: (json['fullname'] ?? '').toString(),
        avatarUrl: json['avatar'] as String? ?? json['avatarUrl'] as String?,
      );
}
