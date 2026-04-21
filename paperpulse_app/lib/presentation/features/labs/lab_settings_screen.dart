import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/lab.dart';
import '../../../data/models/lab_pref.dart';
import '../../../data/providers/lab_catalog_provider.dart';
import '../../../data/providers/lab_prefs_provider.dart';
import '../../../services/lab_notification_service.dart';

class LabSettingsScreen extends ConsumerWidget {
  const LabSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final labsAsync = ref.watch(labCatalogProvider);
    final prefsAsync = ref.watch(labPrefsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Labs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: labsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.sageGreen)),
        error: (_, __) => const Center(child: Text('Failed to load labs')),
        data: (labs) {
          final prefs = prefsAsync.asData?.value ?? const <String, LabPref>{};
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: labs.length + 1,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.lightGray),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Text(
                    'Show in Browse adds a chip for this lab. Favourite also sends '
                    'a daily notification when they publish new papers.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.midGray),
                  ),
                );
              }
              final lab = labs[index - 1];
              final pref = prefs[lab.id] ?? const LabPref();
              return _LabRow(lab: lab, pref: pref, ref: ref, theme: theme);
            },
          );
        },
      ),
    );
  }
}

class _LabRow extends StatelessWidget {
  const _LabRow({
    required this.lab,
    required this.pref,
    required this.ref,
    required this.theme,
  });

  final Lab lab;
  final LabPref pref;
  final WidgetRef ref;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.sageLight,
            backgroundImage:
                lab.avatarUrl != null ? NetworkImage(lab.avatarUrl!) : null,
            child: lab.avatarUrl == null
                ? Text(
                    lab.displayName.characters.first,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: AppColors.sageDark),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              lab.displayName,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            tooltip: pref.favourited ? 'Unfavourite' : 'Favourite',
            icon: Icon(
              pref.favourited ? Icons.star : Icons.star_border,
              color: pref.favourited ? AppColors.sageDark : AppColors.midGray,
            ),
            onPressed: () async {
              final willBeFavourited = !pref.favourited;
              await ref
                  .read(labPrefsProvider.notifier)
                  .setFavourited(lab.id, willBeFavourited);
              if (willBeFavourited) {
                await requestNotificationPermission();
              }
            },
          ),
          const SizedBox(width: 4),
          Switch(
            value: pref.displayed,
            activeThumbColor: AppColors.sageDark,
            onChanged: (v) => ref
                .read(labPrefsProvider.notifier)
                .setDisplayed(lab.id, v),
          ),
        ],
      ),
    );
  }
}
