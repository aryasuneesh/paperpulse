import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/curiosity_card.dart';
import '../library/providers/bookmark_provider.dart';
import 'html_reader_screen.dart';
import 'pdf_reader_screen.dart';
import 'providers/streak_provider.dart';
import 'share_card_sheet.dart';
import 'widgets/streak_popup.dart';

class PaperDetailModal extends ConsumerWidget {
  const PaperDetailModal({required this.paper, super.key});

  final Paper paper;

  static void show(BuildContext context, Paper paper) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaperDetailModal(paper: paper),
    );
  }

  Future<void> _openReader(
    BuildContext context,
    WidgetRef ref, {
    required bool useHtml,
  }) async {
    // Capture root navigator before any async gap — context may be unmounted
    // after await, but the root navigator reference stays valid.
    final rootNav = Navigator.of(context, rootNavigator: true);
    ref.read(bookmarkProvider.notifier).markAsInProgress(paper);
    final didIncrement =
        await ref.read(streakProvider.notifier).markActivity();
    if (!context.mounted) return;
    if (didIncrement) {
      await StreakPopup.show(context, ref.read(streakProvider));
      if (!context.mounted) return;
    }
    Navigator.pop(context); // close modal (branch navigator)
    rootNav.push(
      MaterialPageRoute(
        builder: (_) => useHtml
            ? HtmlReaderScreen(paper: paper)
            : PdfReaderScreen(paper: paper),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArxiv = paper.source == PaperSource.arxiv;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.paperWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              CuriosityCard(
                paper: paper,
                isScrollable: false,
                onBookmarkTap: () {
                  ref.read(bookmarkProvider.notifier).toggleBookmark(paper);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Library updated',
                        style: TextStyle(color: AppColors.inkBlack),
                      ),
                      backgroundColor: AppColors.sageGreen,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                onShareTap: () => ShareCardSheet.show(context, paper),
                onReadPdfTap: () =>
                    _openReader(context, ref, useHtml: false),
                onReadHtmlTap: isArxiv
                    ? () => _openReader(context, ref, useHtml: true)
                    : null,
              ),

              const SizedBox(height: 32),

              Text(
                'About this paper',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              _buildMetadataRow('Source', paper.source.name.toUpperCase()),
              _buildMetadataRow('Published', '${paper.publishedAt.year}'),
              _buildMetadataRow(
                'Citations',
                paper.citationCount == 0 ? 'N/A' : '${paper.citationCount}',
                isHighlight: true,
              ),

              const SizedBox(height: 32),

              Text(
                'Authors',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: paper.authors.map((author) {
                  return Chip(
                    label: Text(author),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.inkBlack,
                    ),
                    backgroundColor: AppColors.paperWhite,
                    side: const BorderSide(color: AppColors.lightGray),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                }).toList(),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildMetadataRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.midGray, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppColors.sageDark : AppColors.inkBlack,
              fontWeight:
                  isHighlight ? FontWeight.bold : FontWeight.w500,
              fontFamily: isHighlight ? 'JetBrains Mono' : 'Quicksand',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
