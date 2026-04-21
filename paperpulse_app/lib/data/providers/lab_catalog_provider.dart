import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lab.dart';
import '../models/paper_organization.dart';
import '../repositories/lab_catalog_repository.dart';

final labCatalogRepositoryProvider =
    Provider<LabCatalogRepository>((_) => LabCatalogRepository());

final labCatalogProvider =
    AsyncNotifierProvider<LabCatalogNotifier, List<Lab>>(LabCatalogNotifier.new);

class LabCatalogNotifier extends AsyncNotifier<List<Lab>> {
  @override
  Future<List<Lab>> build() =>
      ref.read(labCatalogRepositoryProvider).load();
}

/// Returns the matching lab id for [org], or null if no catalog entry matches.
/// Aliases MUST already be lowercase. First match in [labs] wins.
String? resolveLabId(PaperOrganization? org, List<Lab> labs) {
  if (org == null) return null;
  final needle1 = org.name.toLowerCase();
  final needle2 = org.fullname.toLowerCase();
  final needle3 = org.fullname.toLowerCase().replaceAll(' ', '-');
  for (final lab in labs) {
    for (final alias in lab.aliases) {
      if (alias == needle1 || alias == needle2 || alias == needle3) {
        return lab.id;
      }
    }
  }
  return null;
}
