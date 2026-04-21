import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/bookmark.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/compact_paper_card.dart';
import '../digest/paper_detail_modal.dart';
import 'highlights_section.dart';
import 'providers/bookmark_provider.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
                  labelStyle: theme.textTheme.labelMedium
                      ?.copyWith(fontSize: 12),
                  unselectedLabelStyle: theme.textTheme.labelMedium
                      ?.copyWith(fontSize: 12),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Unread'),
                    Tab(text: 'In Progress'),
                    Tab(text: 'Finished'),
                    Tab(text: 'Highlights'),
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
                  const HighlightsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperList(BookmarkStatus status) {
    final bookmarks = ref.watch(bookmarkProvider);
    final papers = bookmarks
        .where((b) => b.status == status)
        .map((b) => b.paper)
        .toList();

    if (papers.isEmpty) {
      return _buildEmptyState(switch (status) {
        BookmarkStatus.unread =>
          'No unread papers.\nSwipe right on any card to save one!',
        BookmarkStatus.in_progress => 'No papers in progress yet.',
        BookmarkStatus.finished => "You haven't finished any papers yet.",
      });
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: papers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final paper = papers[index];
        return _LibraryPaperItem(
          paper: paper,
          currentStatus: status,
          onOpen: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PaperDetailModal(paper: paper),
          ),
          onRemove: () {
            ref.read(bookmarkProvider.notifier).toggleBookmark(paper);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from Library')),
            );
          },
          onStatusChange: (newStatus) {
            ref
                .read(bookmarkProvider.notifier)
                .updateStatus(paper.id, newStatus);
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
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.midGray),
        ),
      ),
    );
  }
}

/// Library list item with swipe-to-delete and a status-change popup menu.
class _LibraryPaperItem extends StatelessWidget {
  const _LibraryPaperItem({
    required this.paper,
    required this.currentStatus,
    required this.onOpen,
    required this.onRemove,
    required this.onStatusChange,
  });

  final Paper paper;
  final BookmarkStatus currentStatus;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final ValueChanged<BookmarkStatus> onStatusChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        child: const Icon(Icons.delete_outline, color: AppColors.inkBlack),
      ),
      onDismissed: (_) => onRemove(),
      child: Stack(
        children: [
          CompactPaperCard(paper: paper, onTap: onOpen),
          Positioned(
            top: 8,
            right: 8,
            child: _StatusMenu(
              current: currentStatus,
              theme: theme,
              onSelect: onStatusChange,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMenu extends StatelessWidget {
  const _StatusMenu({
    required this.current,
    required this.theme,
    required this.onSelect,
  });

  final BookmarkStatus current;
  final ThemeData theme;
  final ValueChanged<BookmarkStatus> onSelect;

  static const _labels = {
    BookmarkStatus.unread: 'Unread',
    BookmarkStatus.in_progress: 'In Progress',
    BookmarkStatus.finished: 'Finished',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BookmarkStatus>(
      tooltip: 'Change status',
      padding: EdgeInsets.zero,
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _chipColor(current),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Text(
          _labels[current]!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.sageDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onSelected: onSelect,
      itemBuilder: (_) => BookmarkStatus.values
          .where((s) => s != current)
          .map((s) => PopupMenuItem(
                value: s,
                child: Text(_labels[s]!, style: theme.textTheme.bodyMedium),
              ))
          .toList(),
    );
  }

  Color _chipColor(BookmarkStatus s) => switch (s) {
        BookmarkStatus.unread => AppColors.sageLight,
        BookmarkStatus.in_progress => AppColors.morningHaze,
        BookmarkStatus.finished => AppColors.quietSky,
      };
}
