import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/bookmark.dart';
import '../data/models/paper.dart';

const int digestSizeMin = 5;
const int digestSizeMax = 50;
const int digestSizeDefault = 10;
const int _topicSignalThreshold = 5;

const _prefsDigestSizeKey = 'paperpulse_digest_size';
const _prefsDailyEnabledKey = 'paperpulse_daily_notif_enabled';
const _prefsInterestTopicsKey = 'paperpulse_interest_topics';

Future<List<String>> loadInterestTopics() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_prefsInterestTopicsKey) ?? const [];
}

Future<void> saveInterestTopics(Set<String> topics) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_prefsInterestTopicsKey, topics.toList());
}

Future<int> loadDigestSize() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_prefsDigestSizeKey) ?? digestSizeDefault;
}

Future<void> saveDigestSize(int size) async {
  final clamped = size.clamp(digestSizeMin, digestSizeMax);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_prefsDigestSizeKey, clamped);
}

Future<bool> loadDailyNotifEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_prefsDailyEnabledKey) ?? false;
}

Future<void> saveDailyNotifEnabled(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_prefsDailyEnabledKey, enabled);
}

Map<String, int> topicSignalFromBookmarks(List<Bookmark> bookmarks) {
  final counts = <String, int>{};
  for (final b in bookmarks) {
    for (final t in b.topicTags) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
  }
  return counts;
}

/// Combined signal: +1 per interest-picker topic, plus bookmark tag counts.
/// Additive — a topic picked in onboarding AND present in 2 bookmarks scores 3.
Map<String, int> topicSignal({
  required List<String> interestTopics,
  required List<Bookmark> bookmarks,
}) {
  final counts = <String, int>{};
  for (final t in interestTopics) {
    counts[t] = (counts[t] ?? 0) + 1;
  }
  for (final b in bookmarks) {
    for (final t in b.topicTags) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
  }
  return counts;
}

List<Paper> selectPersonalizedPapers({
  required List<Paper> papers,
  required Map<String, int> signal,
  required int size,
}) {
  if (papers.isEmpty) return const [];
  if (signal.isEmpty) return papers.take(size).toList();
  final scored = papers.map((p) {
    var score = 0;
    for (final tag in p.topicTags) {
      score += signal[tag] ?? 0;
    }
    return (paper: p, score: score);
  }).toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  return scored.take(size).map((e) => e.paper).toList();
}

bool hasEnoughTopicSignal(int bookmarkCount) =>
    bookmarkCount >= _topicSignalThreshold;

/// Papers NOT in [excludeIds], sorted by topic-signal overlap (desc).
/// Falls back to original order when there is no topic signal yet.
List<Paper> selectExtendedPapers({
  required List<Paper> papers,
  required Map<String, int> signal,
  required Set<String> excludeIds,
}) {
  final pool = papers.where((p) => !excludeIds.contains(p.id)).toList();
  if (pool.isEmpty) return const [];
  if (signal.isEmpty) return pool;
  final scored = pool.map((p) {
    var score = 0;
    for (final tag in p.topicTags) {
      score += signal[tag] ?? 0;
    }
    return (paper: p, score: score);
  }).toList()
    ..sort((a, b) => b.score.compareTo(a.score));
  return scored.map((e) => e.paper).toList();
}
