import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/lab.dart';
import '../../../data/models/paper.dart';
import '../../../data/providers/lab_catalog_provider.dart';
import '../../../data/providers/lab_prefs_provider.dart';
import '../../../data/providers/papers_provider.dart';
import '../../common_widgets/compact_paper_card.dart';
import '../digest/paper_detail_modal.dart';

const _browseTopics = [
  'All',
  'Machine Learning',
  'Computer Vision',
  'Language Models',
  'Generative AI',
  'Robotics',
  'Reinforcement Learning',
  'Multimodal AI',
  'Audio & Speech',
  'AI Safety',
];

const _allLabId = '__all__';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String _selectedTopic = 'All';
  String _selectedLabId = _allLabId;
  String _searchQuery = '';

  List<Paper> _filter(List<Paper> papers, List<Lab> labs) {
    var list = papers;
    if (_selectedTopic != 'All') {
      list = list.where((p) => p.topicTags.contains(_selectedTopic)).toList();
    }
    if (_selectedLabId != _allLabId) {
      list = list
          .where((p) => resolveLabId(p.organization, labs) == _selectedLabId)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.authors.any((a) => a.toLowerCase().contains(q)) ||
              p.topicTags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    return list;
  }

  /// Labs that have at least one paper in today's feed.
  List<Lab> _visibleLabs(
      List<Paper> papers, List<Lab> labs, Set<String> displayedIds) {
    final present = <String>{};
    for (final p in papers) {
      final id = resolveLabId(p.organization, labs);
      if (id != null) present.add(id);
    }
    return labs
        .where((l) => present.contains(l.id) && displayedIds.contains(l.id))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final papersAsync = ref.watch(papersProvider);
    final labsAsync = ref.watch(labCatalogProvider);
    final prefsAsync = ref.watch(labPrefsProvider);
    final prefsMap = prefsAsync.asData?.value;
    final displayedIds = prefsMap == null
        ? <String>{}
        : prefsMap.entries
            .where((e) => e.value.displayed)
            .map((e) => e.key)
            .toSet();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text('Browse', style: theme.textTheme.headlineLarge),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search topics, authors, keywords...',
                  hintStyle: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.midGray),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.midGray),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.sageDark),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Topic chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _browseTopics.length,
                itemBuilder: (context, index) {
                  final topic = _browseTopics[index];
                  final isSelected = _selectedTopic == topic;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(topic),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedTopic = topic),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppColors.paperWhite
                            : AppColors.sageDark,
                      ),
                      backgroundColor: AppColors.sageLight,
                      selectedColor: AppColors.inkBlack,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.inkBlack
                            : AppColors.sageGreen,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            // Lab chips (only when catalog loaded AND today's feed has matches)
            _LabChipRow(
              papersAsync: papersAsync,
              labsAsync: labsAsync,
              selectedLabId: _selectedLabId,
              onSelect: (id) => setState(() => _selectedLabId = id),
              visibleLabsFn: _visibleLabs,
              displayedIds: displayedIds,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _buildFeed(theme, papersAsync, labsAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(
    ThemeData theme,
    AsyncValue<List<Paper>> papersAsync,
    AsyncValue<List<Lab>> labsAsync,
  ) {
    return papersAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.sageGreen)),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.midGray, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load papers', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(papersProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageDark,
                foregroundColor: AppColors.paperWhite,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (all) {
        final labs = labsAsync.asData?.value ?? const <Lab>[];
        final papers = _filter(all, labs);
        if (papers.isEmpty) {
          return Center(
            child: Text(
              _selectedTopic == 'All' && _selectedLabId == _allLabId
                  ? 'No papers available.'
                  : 'No papers match the current filters.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: papers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => CompactPaperCard(
            paper: papers[index],
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    PaperDetailModal(paper: papers[index]),
              );
            },
          ),
        );
      },
    );
  }
}

class _LabChipRow extends StatelessWidget {
  const _LabChipRow({
    required this.papersAsync,
    required this.labsAsync,
    required this.selectedLabId,
    required this.onSelect,
    required this.visibleLabsFn,
    required this.displayedIds,
  });

  final AsyncValue<List<Paper>> papersAsync;
  final AsyncValue<List<Lab>> labsAsync;
  final String selectedLabId;
  final ValueChanged<String> onSelect;
  final List<Lab> Function(List<Paper>, List<Lab>, Set<String>) visibleLabsFn;
  final Set<String> displayedIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final papers = papersAsync.asData?.value;
    final labs = labsAsync.asData?.value;
    if (papers == null || labs == null) {
      return const SizedBox.shrink();
    }

    final visible = visibleLabsFn(papers, labs, displayedIds);
    if (visible.isEmpty) return const SizedBox.shrink();

    final entries = <_LabChipEntry>[
      _LabChipEntry(id: _allLabId, label: 'All Labs', avatar: null),
      ...visible.map((l) => _LabChipEntry(
            id: l.id,
            label: l.displayName,
            avatar: l.avatarUrl ?? _pickPaperAvatar(papers, l.id),
          )),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final e = entries[index];
            final isSelected = selectedLabId == e.id;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                avatar: e.avatar != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(e.avatar!),
                        radius: 10,
                      )
                    : null,
                label: Text(e.label),
                selected: isSelected,
                onSelected: (_) => onSelect(e.id),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppColors.paperWhite
                      : AppColors.sageDark,
                ),
                backgroundColor: AppColors.sageLight,
                selectedColor: AppColors.inkBlack,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.inkBlack
                      : AppColors.sageGreen,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                showCheckmark: false,
              ),
            );
          },
        ),
      ),
    );
  }

  static String? _pickPaperAvatar(List<Paper> papers, String labId) {
    for (final p in papers) {
      if (p.organization?.avatarUrl != null) {
        return p.organization!.avatarUrl;
      }
    }
    return null;
  }
}

class _LabChipEntry {
  final String id;
  final String label;
  final String? avatar;
  _LabChipEntry({required this.id, required this.label, this.avatar});
}
