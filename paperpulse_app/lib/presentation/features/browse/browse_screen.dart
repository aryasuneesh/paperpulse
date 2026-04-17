import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../../data/providers/papers_provider.dart';
import '../../common_widgets/compact_paper_card.dart';
import '../digest/paper_detail_modal.dart';

// These match the actual topics inferred from HuggingFace Daily Papers (ML/AI domain)
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

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String _selectedTopic = 'All';
  String _searchQuery = '';

  List<Paper> _filter(List<Paper> papers) {
    var list = papers;
    if (_selectedTopic != 'All') {
      list = list
          .where((p) => p.topicTags.contains(_selectedTopic))
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final papersAsync = ref.watch(papersProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text('Browse', style: theme.textTheme.headlineLarge),
            ),

            // Search Bar
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

            // Filter Chips
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

            const SizedBox(height: 16),

            Expanded(child: _buildFeed(theme, papersAsync)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(ThemeData theme, AsyncValue<List<Paper>> papersAsync) {
    return papersAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.sageGreen)),
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
        final papers = _filter(all);
        if (papers.isEmpty) {
          return Center(
            child: Text(
              _selectedTopic == 'All'
                  ? 'No papers available.'
                  : 'No papers found for "$_selectedTopic".',
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
                builder: (context) => PaperDetailModal(paper: papers[index]),
              );
            },
          ),
        );
      },
    );
  }
}
