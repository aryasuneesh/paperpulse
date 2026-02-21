import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/compact_paper_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Paper> _mockSavedPapers = List.generate(
    5,
    (index) => Paper(
      id: 'lib_$index',
      title: 'Saved Paper Title $index',
      authors: ['Author $index'],
      source: PaperSource.semantic_scholar,
      sourceUrl: '',
      publishedAt: DateTime.now(),
      topicTags: ['Neuroscience'],
      curiosityHook: 'Focus on library.',
    ),
  );

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
                  _buildPaperList(), // Unread
                  _buildEmptyState('No papers in progress.'),
                  _buildEmptyState('You haven\'t finished any papers yet.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _mockSavedPapers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey(_mockSavedPapers[index].id),
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
          onDismissed: (_) {
            setState(() {
              _mockSavedPapers.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from Library')),
            );
          },
          child: CompactPaperCard(paper: _mockSavedPapers[index], onTap: () {}),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
      ),
    );
  }
}
