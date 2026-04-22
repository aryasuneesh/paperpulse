import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';

class CuriosityCard extends StatelessWidget {
  const CuriosityCard({
    required this.paper,
    this.onBookmarkTap,
    this.onShareTap,
    this.onReadFullTap,
    this.onReadPdfTap,
    this.onReadHtmlTap,
    this.isScrollable = true,
    super.key,
  });

  final Paper paper;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onShareTap;
  /// Legacy: used in digest stack to open PaperDetailModal.
  final VoidCallback? onReadFullTap;
  /// Two-button mode: open PDF reader directly.
  final VoidCallback? onReadPdfTap;
  /// Two-button mode: open HTML reader directly (ArXiv only).
  final VoidCallback? onReadHtmlTap;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inkBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTopicTag(theme), _buildSourceBadge(theme)],
          ),
          const SizedBox(height: 16),
          Text(
            paper.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.paperWhite,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _formatAuthors(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.lightGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          if (isScrollable)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  paper.curiosityHook,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.paperWhite,
                  ),
                ),
              ),
            )
          else
            Text(
              paper.curiosityHook,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.paperWhite,
              ),
            ),
          const SizedBox(height: 32),
          _buildCta(theme),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionIcon(
                icon: Icons.bookmark_outline,
                label: 'Save',
                onTap: onBookmarkTap,
                theme: theme,
              ),
              _buildActionIcon(
                icon: Icons.ios_share,
                label: 'Share',
                onTap: onShareTap,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCta(ThemeData theme) {
    // Two-button mode: PDF + HTML
    if (onReadPdfTap != null && onReadHtmlTap != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReadPdfTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: AppColors.paperWhite,
                side: const BorderSide(color: AppColors.midGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Open PDF'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: onReadHtmlTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.sageGreen,
                foregroundColor: AppColors.inkBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Open HTML'),
            ),
          ),
        ],
      );
    }

    // Single PDF button (non-ArXiv two-button mode)
    if (onReadPdfTap != null) {
      return ElevatedButton(
        onPressed: onReadPdfTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.sageGreen,
          foregroundColor: AppColors.inkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text('Open PDF'),
      );
    }

    // Legacy single button (opens modal from digest stack)
    return ElevatedButton(
      onPressed: onReadFullTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.sageGreen,
        foregroundColor: AppColors.inkBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Text('Read Full Paper →'),
    );
  }

  Widget _buildTopicTag(ThemeData theme) {
    if (paper.topicTags.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.sageGreen),
      ),
      child: Text(
        paper.topicTags.first.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.inkBlack,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSourceBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.midGray),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        paper.source.name.toUpperCase(),
        style: theme.textTheme.labelSmall,
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.paperWhite),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.paperWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAuthors() {
    if (paper.authors.isEmpty) return 'Unknown';
    if (paper.authors.length == 1) return paper.authors.first;
    return '${paper.authors.first} et al.';
  }
}
