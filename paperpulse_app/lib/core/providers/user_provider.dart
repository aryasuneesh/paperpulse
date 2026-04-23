import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart' show sharedPrefs;

const _deviceUuidKey = 'paperpulse_device_uuid';

String _generateUuidV4() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  // Set version 4 bits
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  // Set variant bits
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  return '${hex(bytes.sublist(0, 4))}-${hex(bytes.sublist(4, 6))}-'
      '${hex(bytes.sublist(6, 8))}-${hex(bytes.sublist(8, 10))}-'
      '${hex(bytes.sublist(10, 16))}';
}

/// Stable device-local UUID (persists across app restarts).
/// PaperPulse identifies users purely by device in the beta — no cloud auth.
final currentUserIdProvider = Provider<String>((ref) {
  final stored = sharedPrefs.getString(_deviceUuidKey);
  if (stored != null && stored.isNotEmpty) return stored;

  final newId = _generateUuidV4();
  sharedPrefs.setString(_deviceUuidKey, newId);
  return newId;
});
