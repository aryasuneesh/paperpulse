import 'package:flutter_test/flutter_test.dart';
import 'package:paperpulse_app/data/models/lab.dart';
import 'package:paperpulse_app/data/models/paper_organization.dart';
import 'package:paperpulse_app/data/providers/lab_catalog_provider.dart';

void main() {
  const deepmind = Lab(
    id: 'deepmind',
    displayName: 'Google DeepMind',
    aliases: ['google-deepmind', 'deepmind'],
  );
  const google = Lab(
    id: 'google',
    displayName: 'Google',
    aliases: ['google'],
  );
  const labs = [deepmind, google];

  test('returns null when org is null', () {
    expect(resolveLabId(null, labs), isNull);
  });

  test('matches by name slug', () {
    final id = resolveLabId(
      PaperOrganization(id: 'x', name: 'google-deepmind', fullname: 'Google DeepMind'),
      labs,
    );
    expect(id, 'deepmind');
  });

  test('matches by fullname case-insensitively', () {
    final id = resolveLabId(
      PaperOrganization(id: 'x', name: 'something-else', fullname: 'Google DeepMind'),
      labs,
    );
    expect(id, 'deepmind');
  });

  test('first-in-list wins for tie (deepmind before google)', () {
    final id = resolveLabId(
      PaperOrganization(id: 'x', name: 'google-deepmind', fullname: 'Google'),
      labs,
    );
    expect(id, 'deepmind');
  });

  test('returns null on no match', () {
    final id = resolveLabId(
      PaperOrganization(id: 'x', name: 'simular-ai', fullname: 'Simular'),
      labs,
    );
    expect(id, isNull);
  });
}
