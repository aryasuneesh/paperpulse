import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../../data/providers/papers_provider.dart';
import '../library/providers/bookmark_provider.dart';

const int _onboardingPickerTarget = 5;

class SampleCardsScreen extends ConsumerStatefulWidget {
  const SampleCardsScreen({super.key});

  @override
  ConsumerState<SampleCardsScreen> createState() => _SampleCardsScreenState();
}

class _SampleCardsScreenState extends ConsumerState<SampleCardsScreen> {
  final Set<String> _selectedIds = {};

  void _toggle(Paper p) {
    setState(() {
      if (_selectedIds.contains(p.id)) {
        _selectedIds.remove(p.id);
      } else {
        _selectedIds.add(p.id);
      }
    });
  }

  void _onContinue(List<Paper> papers) {
    final notifier = ref.read(bookmarkProvider.notifier);
    for (final p in papers.where((p) => _selectedIds.contains(p.id))) {
      if (!notifier.isBookmarked(p.id)) {
        notifier.toggleBookmark(p);
      }
    }
    context.push('/onboarding/account');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final papersAsync = ref.watch(papersProvider);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Pick 5 papers you'd read",
                  style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                "We'll use these to personalize your digest.",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.midGray, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: papersAsync.when(
                  data: (papers) => ListView.separated(
                    itemCount: papers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = papers[i];
                      final selected = _selectedIds.contains(p.id);
                      return _PickerRow(
                        paper: p,
                        selected: selected,
                        onTap: () => _toggle(p),
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Could not load papers: $e')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ElevatedButton(
                  onPressed: _selectedIds.length >= _onboardingPickerTarget
                      ? () => _onContinue(papersAsync.asData?.value ?? const [])
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Continue (${_selectedIds.length}/$_onboardingPickerTarget) →',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.paper,
    required this.selected,
    required this.onTap,
  });

  final Paper paper;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.sageLight : theme.colorScheme.surface,
          border: Border.all(
            color: selected ? AppColors.sageGreen : AppColors.lightGray,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.sageDark : AppColors.midGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper.title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (paper.topicTags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      paper.topicTags.join(' · '),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: AppColors.midGray),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
