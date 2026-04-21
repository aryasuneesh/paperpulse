import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paperpulse_app/data/repositories/lab_catalog_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bundled = '''
{ "version": 1, "labs": [
  { "id": "a", "displayName": "A", "avatarUrl": null, "aliases": ["a"] }
]}
''';

const _remoteV2 = '''
{ "version": 2, "labs": [
  { "id": "a", "displayName": "A", "avatarUrl": null, "aliases": ["a"] },
  { "id": "b", "displayName": "B", "avatarUrl": null, "aliases": ["b"] }
]}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns bundled labs when remote fetch fails', () async {
    final client = MockClient((_) async => http.Response('', 500));
    final repo = LabCatalogRepository(
      client: client,
      bundledLoader: () async => _bundled,
    );
    final labs = await repo.load();
    expect(labs.map((l) => l.id), ['a']);
  });

  test('overrides with remote when version is newer', () async {
    final client = MockClient((_) async => http.Response(_remoteV2, 200));
    final repo = LabCatalogRepository(
      client: client,
      bundledLoader: () async => _bundled,
    );
    final labs = await repo.load();
    expect(labs.map((l) => l.id), ['a', 'b']);
  });

  test('ignores remote with lower or equal version', () async {
    final client =
        MockClient((_) async => http.Response(_bundled, 200)); // version 1
    final repo = LabCatalogRepository(
      client: client,
      bundledLoader: () async => _bundled,
    );
    final labs = await repo.load();
    expect(labs.map((l) => l.id), ['a']); // bundled wins tie
  });

  test('caches successful remote for later offline launches', () async {
    SharedPreferences.setMockInitialValues({
      'lab_catalog_cache_v1': _remoteV2,
    });
    final client = MockClient((_) async => http.Response('', 500));
    final repo = LabCatalogRepository(
      client: client,
      bundledLoader: () async => _bundled,
    );
    final labs = await repo.load();
    expect(labs.map((l) => l.id), ['a', 'b']);
  });
}
