import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/bookmark.dart';
import '../../../data/models/paper.dart';
import '../../../data/repositories/paper_repository.dart';
import '../../common_widgets/compact_paper_card.dart';
import '../digest/paper_detail_modal.dart';
import 'providers/bookmark_provider.dart';

final dailyPapersProvider = FutureProvider<List<Paper>>((ref) {
  return ref.watch(paperRepositoryProvider).fetchDailyPapers();
});

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              child: Text('Library', style: theme.textTheme.headlineLarge),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.inkBlack,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: AppColors.paperWhite,
                  unselectedLabelColor: AppColors.midGray,
                  labelStyle: theme.textTheme.labelMedium,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Unread'),
                    Tab(text: 'In Progress'),
                    Tab(text: 'Finished'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPaperList(BookmarkStatus.unread),
                  _buildPaperList(BookmarkStatus.in_progress),
                  _buildPaperList(BookmarkStatus.finished),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperList(BookmarkStatus status) {
    // Watch the actual state to trigger rebuilds dynamically when a bookmark is added/removed
    final bookmarks = ref.watch(bookmarkProvider);
    final bookmarkedIds = bookmarks
        .where((b) => b.status == status)
        .map((b) => b.paperId)
        .toSet();

    if (bookmarkedIds.isEmpty) {
      return _buildEmptyState(
        status == BookmarkStatus.unread
            ? 'No unread papers. Swipe right in Digest to save!'
            : status == BookmarkStatus.in_progress
            ? 'No papers in progress.'
            : 'You haven\'t finished any papers yet.',
      );
    }

    // Usually we would query a database for just these IDs.
    // For now, we'll fetch all daily papers and filter them.
    final asyncPapers = ref.watch(dailyPapersProvider);

    return asyncPapers.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.sageGreen),
      ),
      error: (err, stack) => _buildEmptyState('Failed to load papers.'),
      data: (allPapers) {
        final filteredPapers = allPapers
            .where((p) => bookmarkedIds.contains(p.id))
            .toList();

        if (filteredPapers.isEmpty) {
          return _buildEmptyState('Saved papers no longer available.');
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: filteredPapers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final paper = filteredPapers[index];
            return Dismissible(
              key: ValueKey(paper.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.cherryBlossom,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.inkBlack,
                ),
              ),
              onDismissed: (_) {
                ref.read(bookmarkProvider.notifier).toggleBookmark(paper);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removed from Library')),
                );
              },
              child: CompactPaperCard(
                paper: paper,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => PaperDetailModal(paper: paper),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
        ),
      ),
    );
  }
}
