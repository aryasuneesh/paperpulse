class Lab {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final List<String> aliases;

  const Lab({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.aliases,
  });

  factory Lab.fromJson(Map<String, dynamic> json) => Lab(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        aliases: (json['aliases'] as List)
            .map((e) => e.toString().toLowerCase())
            .toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'aliases': aliases,
      };
}
