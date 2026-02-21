class User {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;
  final bool isPro;
  final List<String> interestTopics;
  final DigestDay digestDay;
  final DigestTime digestTime;
  final int streakCount;
  final bool streakShieldUsed;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    this.isPro = false,
    this.interestTopics = const [],
    this.digestDay = DigestDay.mon,
    this.digestTime = DigestTime.morning,
    this.streakCount = 0,
    this.streakShieldUsed = false,
  });
}

enum DigestDay { mon, wed, fri }

enum DigestTime { morning, evening }
