import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';

class CuriosityCard extends StatelessWidget {
  const CuriosityCard({
    required this.paper,
    this.onBookmarkTap,
    this.onShareTap,
    this.onReadFullTap,
    super.key,
  });

  final Paper paper;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onReadFullTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dark card for CuriosityCard (Ink Black background)
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Topic Tag and Source Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTopicTag(theme), _buildSourceBadge(theme)],
          ),
          const SizedBox(height: 16),
          // Paper Title
          Text(
            paper.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.paperWhite,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Author & Institution metadata
          Text(
            '${_formatAuthors()} • ${paper.institution ?? 'Independent'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.lightGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          // Curiosity Hook Synopsis
          Text(
            paper.curiosityHook,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.paperWhite,
            ),
          ),
          const SizedBox(height: 32),
          // CTA Button
          ElevatedButton(
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
          ),
          const SizedBox(height: 24),
          // Action Row
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
                icon: Icons.edit_outlined,
                label: 'Highlight',
                onTap: () {
                  // Pro feature hook
                },
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
          color: AppColors.sageGreen,
          fontWeight: FontWeight.bold, // fallback for Geist Mono
        ), // Typically handled by tag style in typography
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
