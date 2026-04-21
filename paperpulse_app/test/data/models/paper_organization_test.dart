import 'package:flutter_test/flutter_test.dart';
import 'package:paperpulse_app/data/models/paper_organization.dart';

void main() {
  group('PaperOrganization', () {
    test('fromJson parses all fields', () {
      final org = PaperOrganization.fromJson({
        '_id': '63f9b97fac8368a4dce39668',
        'name': 'simular-ai',
        'fullname': 'Simular',
        'avatar': 'https://example.com/a.png',
      });
      expect(org.id, '63f9b97fac8368a4dce39668');
      expect(org.name, 'simular-ai');
      expect(org.fullname, 'Simular');
      expect(org.avatarUrl, 'https://example.com/a.png');
    });

    test('fromJson tolerates missing avatar', () {
      final org = PaperOrganization.fromJson({
        '_id': 'x',
        'name': 'n',
        'fullname': 'N',
      });
      expect(org.avatarUrl, isNull);
    });

    test('toJson round-trips', () {
      final org = PaperOrganization(
        id: 'x', name: 'n', fullname: 'N', avatarUrl: 'a',
      );
      final round = PaperOrganization.fromJson(org.toJson());
      expect(round.id, 'x');
      expect(round.name, 'n');
      expect(round.fullname, 'N');
      expect(round.avatarUrl, 'a');
    });
  });
}
