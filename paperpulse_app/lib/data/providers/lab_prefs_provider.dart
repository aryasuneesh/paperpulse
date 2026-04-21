import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lab_pref.dart';
import '../../services/lab_notification_service.dart';

const _storageKey = 'lab_prefs_v1';

final labPrefsProvider =
    AsyncNotifierProvider<LabPrefsNotifier, Map<String, LabPref>>(
        LabPrefsNotifier.new);

class LabPrefsNotifier extends AsyncNotifier<Map<String, LabPref>> {
  @override
  Future<Map<String, LabPref>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return {};
    try {
      final map = (jsonDecode(raw) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, LabPref.fromJson(v as Map<String, dynamic>)),
      );
      return map;
    } catch (_) {
      return {};
    }
  }

  bool isDisplayed(String labId) =>
      state.asData?.value[labId]?.displayed ?? true;
  bool isFavourited(String labId) =>
      state.asData?.value[labId]?.favourited ?? false;

  /// Lab ids explicitly hidden by the user. Labs absent from the map default
  /// to displayed=true, so the canonical filter is "not in hiddenIds".
  Iterable<String> get hiddenIds =>
      (state.asData?.value ?? const <String, LabPref>{})
          .entries
          .where((e) => !e.value.displayed)
          .map((e) => e.key);

  Iterable<String> get favouritedIds =>
      (state.asData?.value ?? const <String, LabPref>{})
          .entries
          .where((e) => e.value.favourited)
          .map((e) => e.key);

  Future<void> setDisplayed(String labId, bool value) async {
    final current = state.asData?.value ?? const <String, LabPref>{};
    final updated = Map<String, LabPref>.from(current);
    final existing = updated[labId] ?? const LabPref();
    updated[labId] = existing.copyWith(
      displayed: value,
      favourited: value ? existing.favourited : false,
    );
    await _save(updated);
    try {
      final anyFav = updated.values.any((p) => p.favourited);
      if (anyFav) {
        await ensureDailyTaskRegistered();
      } else {
        await cancelDailyTask();
      }
    } catch (_) {
      // Workmanager not initialised (test / headless) — safe to ignore.
    }
  }

  Future<void> setFavourited(String labId, bool value) async {
    final current = state.asData?.value ?? const <String, LabPref>{};
    final updated = Map<String, LabPref>.from(current);
    final existing = updated[labId] ?? const LabPref();
    updated[labId] = existing.copyWith(
      favourited: value,
      displayed: value ? true : existing.displayed,
    );
    await _save(updated);
    try {
      final anyFav = updated.values.any((p) => p.favourited);
      if (anyFav) {
        await ensureDailyTaskRegistered();
      } else {
        await cancelDailyTask();
      }
    } catch (_) {
      // Workmanager not initialised (test / headless) — safe to ignore.
    }
  }

  Future<void> _save(Map<String, LabPref> next) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(next.map((k, v) => MapEntry(k, v.toJson()))),
    );
    state = AsyncData(next);
  }
}
