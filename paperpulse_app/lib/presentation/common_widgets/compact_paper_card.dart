import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';

class CompactPaperCard extends StatelessWidget {
  const CompactPaperCard({required this.paper, this.onTap, super.key});

  final Paper paper;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paperWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopicTag(theme),
                Icon(Icons.arrow_forward, size: 16, color: AppColors.midGray),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              paper.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Instrument Serif',
                fontSize: 18,
                color: AppColors.inkBlack,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatAuthors()} • ${paper.source.name.toUpperCase()} • 3 min read', // Read time placeholder
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTag(ThemeData theme) {
    if (paper.topicTags.isEmpty) return const SizedBox();
    return Text(
      paper.topicTags.first.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontFamily: 'JetBrains Mono',
        color: AppColors.sageDark,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatAuthors() {
    if (paper.authors.isEmpty) return 'Unknown';
    if (paper.authors.length == 1) return paper.authors.first;
    return '${paper.authors.first} et al.';
  }
}
