import 'package:workmanager/workmanager.dart';

Future<void> initPlatformDeps(void Function() bgCallback) async {
  await Workmanager().initialize(bgCallback, isInDebugMode: false);
}
