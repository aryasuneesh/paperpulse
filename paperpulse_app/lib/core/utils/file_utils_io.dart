import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<Uint8List?> readAppFile(String name) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    if (await file.exists()) return await file.readAsBytes();
  } catch (_) {}
  return null;
}

Future<void> writeAppFile(String name, List<int> bytes) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
  } catch (_) {}
}
