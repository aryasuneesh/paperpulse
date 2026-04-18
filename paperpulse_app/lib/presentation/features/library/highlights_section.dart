import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/papers_provider.dart';
import '../../../data/models/highlight.dart';
import '../digest/html_reader_screen.dart';
import '../digest/pdf_reader_screen.dart';
import 'providers/highlight_provider.dart';

class HighlightsSection extends ConsumerWidget {
  const HighlightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlights = ref.watch(highlightProvider);
    final papersAsync = ref.watch(papersProvider);

    if (highlights.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'No highlights yet.\nOpen a paper and select text to highlight.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.midGray),
          ),
        ),
      );
    }

    return papersAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.sageGreen),
      ),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Failed to load papers.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.midGray),
          ),
        ),
      ),
      data: (papers) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: highlights.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final h = highlights[index];
            final paper = papers.where((p) => p.id == h.paperId).firstOrNull;
            return _HighlightItem(
              highlight: h,
              paperTitle: paper?.title ?? h.paperId,
              onTap: () {
                if (paper == null) return;
                if (h.readerType == 'html') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HtmlReaderScreen(
                        paper: paper,
                        initialSearchText: h.searchText ?? h.textContent,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfReaderScreen(
                        paper: paper,
                        initialPageNumber: h.pageNumber,
                        initialSearchText: h.textContent,
                      ),
                    ),
                  );
                }
              },
              onDelete: () {
                ref.read(highlightProvider.notifier).removeHighlights([h]);
              },
            );
          },
        );
      },
    );
  }
}

class _HighlightItem extends StatelessWidget {
  const _HighlightItem({
    required this.highlight,
    required this.paperTitle,
    required this.onTap,
    required this.onDelete,
  });

  final Highlight highlight;
  final String paperTitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPdf = highlight.readerType != 'html';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.paperWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPdf
                          ? AppColors.sageLight
                          : AppColors.morningHaze,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isPdf ? 'PDF' : 'HTML',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 9,
                        color: isPdf ? AppColors.sageDark : AppColors.inkBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    highlight.textContent,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paperTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.midGray),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.midGray,
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
