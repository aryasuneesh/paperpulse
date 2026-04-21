import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lab.dart';

typedef BundledLoader = Future<String> Function();

Future<String> _defaultBundledLoader() =>
    rootBundle.loadString('assets/config/labs.json');

class LabCatalogRepository {
  static const String remoteUrl =
      'https://raw.githubusercontent.com/aryasuneesh/paperpulse/main/paperpulse_app/assets/config/labs.json';
  static const String _cacheKey = 'lab_catalog_cache_v1';
  static const Duration _timeout = Duration(seconds: 5);

  final http.Client _client;
  final BundledLoader _bundledLoader;

  LabCatalogRepository({
    http.Client? client,
    BundledLoader? bundledLoader,
  })  : _client = client ?? http.Client(),
        _bundledLoader = bundledLoader ?? _defaultBundledLoader;

  Future<List<Lab>> load() async {
    final bundledRaw = await _bundledLoader();
    final bundled = _parse(bundledRaw);

    final prefs = await SharedPreferences.getInstance();
    final cachedRaw = prefs.getString(_cacheKey);
    var current = _maybeHigher(bundled, cachedRaw);

    try {
      final response =
          await _client.get(Uri.parse(remoteUrl)).timeout(_timeout);
      if (response.statusCode == 200) {
        final remote = _parse(response.body);
        if (remote.version > current.version) {
          await prefs.setString(_cacheKey, response.body);
          current = remote;
        }
      }
    } catch (_) {
      // offline or timeout — fall through with current
    }

    return current.labs;
  }

  _Catalog _maybeHigher(_Catalog bundled, String? cachedRaw) {
    if (cachedRaw == null) return bundled;
    try {
      final cached = _parse(cachedRaw);
      return cached.version > bundled.version ? cached : bundled;
    } catch (_) {
      return bundled;
    }
  }

  _Catalog _parse(String raw) {
    final obj = jsonDecode(raw) as Map<String, dynamic>;
    final version = (obj['version'] as num).toInt();
    final labs = (obj['labs'] as List)
        .map((e) => Lab.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return _Catalog(version: version, labs: labs);
  }
}

class _Catalog {
  final int version;
  final List<Lab> labs;
  _Catalog({required this.version, required this.labs});
}
