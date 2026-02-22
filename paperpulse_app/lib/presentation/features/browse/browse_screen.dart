import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../../data/repositories/paper_repository.dart';
import '../../common_widgets/compact_paper_card.dart';
import '../digest/paper_detail_modal.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final List<String> _topics = [
    'All',
    'Machine Learning',
    'Neuroscience',
    'Climate Science',
    'Physics',
    'Economics',
    'Biology',
  ];

  String _selectedTopic = 'All';
  List<Paper> _papers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPapers();
  }

  Future<void> _fetchPapers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(paperRepositoryProvider);
      final papers = await repository.fetchDailyPapers();

      // Temporary filtering logic since the HF Daily API doesn't have a direct topic search endpoint yet
      // In a real app we'd call a dedicated endpoint `repository.fetchPapersByTopic(topic)`
      if (mounted) {
        setState(() {
          _papers = papers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                decoration: InputDecoration(
                  hintText: 'Search topics, authors, keywords...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.midGray,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.midGray,
                  ),
                  filled: true,
                  fillColor: AppColors.paperWhite,
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
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
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
                itemCount: _topics.length,
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  final isSelected = _selectedTopic == topic;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(topic),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTopic = topic;
                        });
                      },
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

            // Feed
            Expanded(child: _buildFeedContent(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.sageGreen),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.midGray, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load papers', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.midGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPapers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageDark,
                foregroundColor: AppColors.paperWhite,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_papers.isEmpty) {
      return Center(
        child: Text(
          'No papers found for this topic.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _papers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return CompactPaperCard(
          paper: _papers[index],
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PaperDetailModal(paper: _papers[index]),
            );
          },
        );
      },
    );
  }
}
