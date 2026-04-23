import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paper.dart';
import '../repositories/paper_repository.dart';
import '../../services/topics_catalog_service.dart';

const _cacheKey = 'paperpulse_papers_cache';
const _cacheDateKey = 'paperpulse_papers_cache_date';
const _cacheFetchedAtKey = 'paperpulse_papers_cache_fetched_at_ms';
const _cacheDailyDateKey = 'paperpulse_papers_cache_daily_date';

/// Refetch this often even within the same calendar day. Guards against the
/// "HF published after we cached" case: user opens the app before HF's daily
/// drop, we get yesterday's batch, we'd otherwise hold it until midnight.
const Duration _softTtl = Duration(hours: 3);

/// Single source of truth for daily papers across all screens.
///
/// Caching rules (in order):
///   1. If cache date != today → refetch (calendar rollover).
///   2. If cache is older than [_softTtl] → refetch (HF late-publish recovery).
///   3. Otherwise serve the cached list.
///
/// When the fetched payload is itself stale (HF returned a `submittedOnDailyAt`
/// older than today), we keep the previous cache date so the next app open
/// will retry instead of locking today in on yesterday's papers.
final papersProvider =
    AsyncNotifierProvider<PapersNotifier, List<Paper>>(PapersNotifier.new);

class PapersNotifier extends AsyncNotifier<List<Paper>> {
  @override
  Future<List<Paper>> build() => _load();

  Future<List<Paper>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayString();
    final cachedDate = prefs.getString(_cacheDateKey);
    final fetchedAtMs = prefs.getInt(_cacheFetchedAtKey) ?? 0;
    final ageMs = DateTime.now().millisecondsSinceEpoch - fetchedAtMs;

    final calendarFresh = cachedDate == todayStr;
    final ttlFresh = ageMs < _softTtl.inMilliseconds;

    if (calendarFresh && ttlFresh) {
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        try {
          final List<dynamic> decoded = jsonDecode(raw);
          final papers = decoded
              .whereType<Map<String, dynamic>>()
              .map(Paper.fromJson)
              .toList();
          if (papers.isNotEmpty) {
            unawaited(recordTopicsFromPapers(papers));
            return papers;
          }
        } catch (_) {}
      }
    }

    final cachedPapers = _readCachedPapers(prefs);
    try {
      final result =
          await ref.read(paperRepositoryProvider).fetchDailyPapersWithMeta();
      final papers = result.papers;
      if (papers.isEmpty) {
        // Network returned nothing usable — keep whatever cache we had rather
        // than blanking the digest.
        return cachedPapers ?? papers;
      }

      final payloadIsForToday = _sameCalendarDay(result.dailyDate, DateTime.now());
      try {
        await prefs.setString(
            _cacheKey, jsonEncode(papers.map((p) => p.toJson()).toList()));
        await prefs.setInt(
            _cacheFetchedAtKey, DateTime.now().millisecondsSinceEpoch);
        if (result.dailyDate != null) {
          await prefs.setString(
              _cacheDailyDateKey, result.dailyDate!.toIso8601String());
        }
        // Only stamp today's date if HF actually has today's batch. Otherwise
        // keep the old cache date so the next open retries.
        if (payloadIsForToday) {
          await prefs.setString(_cacheDateKey, todayStr);
        }
      } catch (_) {}

      unawaited(recordTopicsFromPapers(papers));
      return papers;
    } catch (e) {
      if (cachedPapers != null) return cachedPapers;
      rethrow;
    }
  }

  List<Paper>? _readCachedPapers(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      final papers = decoded
          .whereType<Map<String, dynamic>>()
          .map(Paper.fromJson)
          .toList();
      return papers.isEmpty ? null : papers;
    } catch (_) {
      return null;
    }
  }

  bool _sameCalendarDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    final local = a.toLocal();
    return local.year == b.year &&
        local.month == b.month &&
        local.day == b.day;
  }

  /// Force a fresh fetch (pull-to-refresh / refresh button).
  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheDateKey);
    await prefs.remove(_cacheFetchedAtKey);
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  String _todayString() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}
