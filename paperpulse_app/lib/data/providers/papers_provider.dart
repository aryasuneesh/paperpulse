import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paper.dart';
import '../repositories/paper_repository.dart';

const _cacheKey = 'paperpulse_papers_cache';
const _cacheDateKey = 'paperpulse_papers_cache_date';

/// Single source of truth for daily papers across all screens.
/// Fetches from the network at most once per calendar day; returns the
/// cached list immediately on subsequent accesses within the same day.
final papersProvider =
    AsyncNotifierProvider<PapersNotifier, List<Paper>>(PapersNotifier.new);

class PapersNotifier extends AsyncNotifier<List<Paper>> {
  @override
  Future<List<Paper>> build() => _load();

  Future<List<Paper>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayString();

    if (prefs.getString(_cacheDateKey) == todayStr) {
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        try {
          final List<dynamic> decoded = jsonDecode(raw);
          final papers = decoded
              .whereType<Map<String, dynamic>>()
              .map(Paper.fromJson)
              .toList();
          if (papers.isNotEmpty) return papers;
        } catch (_) {}
      }
    }

    final papers =
        await ref.read(paperRepositoryProvider).fetchDailyPapers();

    try {
      await prefs.setString(
          _cacheKey, jsonEncode(papers.map((p) => p.toJson()).toList()));
      await prefs.setString(_cacheDateKey, todayStr);
    } catch (_) {}

    return papers;
  }

  /// Force a fresh fetch (e.g. pull-to-refresh). Clears the date cache so
  /// the next [_load] goes to the network.
  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheDateKey);
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  String _todayString() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}
