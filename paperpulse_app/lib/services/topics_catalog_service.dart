import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/paper.dart';

const _prefsTopicsCatalogKey = 'paperpulse_topics_catalog_v1';
const int _topicsCatalogCap = 500;

Future<Set<String>> loadTopicsCatalog() async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_prefsTopicsCatalogKey) ?? const [];
  return list.toSet();
}

/// Accumulate unique topic tags from [papers] into the on-device catalog.
/// Idempotent; order within the stored list is stable for readability.
Future<void> recordTopicsFromPapers(List<Paper> papers) async {
  if (papers.isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  final existing = prefs.getStringList(_prefsTopicsCatalogKey) ?? const [];
  final seen = existing.toSet();
  final merged = [...existing];
  for (final p in papers) {
    for (final t in p.topicTags) {
      final tag = t.trim();
      if (tag.isEmpty) continue;
      if (seen.add(tag)) merged.add(tag);
    }
  }
  if (merged.length == existing.length) return;
  final trimmed = merged.length > _topicsCatalogCap
      ? merged.sublist(merged.length - _topicsCatalogCap)
      : merged;
  await prefs.setStringList(_prefsTopicsCatalogKey, trimmed);
}
