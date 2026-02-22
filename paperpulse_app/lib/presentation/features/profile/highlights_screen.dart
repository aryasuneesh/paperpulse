import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/highlight.dart';
import '../../../data/models/paper.dart';
import '../library/library_screen.dart';
import '../library/providers/highlight_provider.dart';
import '../digest/pdf_reader_screen.dart';

class HighlightsScreen extends ConsumerStatefulWidget {
  const HighlightsScreen({super.key});

  @override
  ConsumerState<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends ConsumerState<HighlightsScreen> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(String highlightId) {
    setState(() {
      if (_selectedIds.contains(highlightId)) {
        _selectedIds.remove(highlightId);
      } else {
        _selectedIds.add(highlightId);
      }
    });
  }

  void _deleteSelected() async {
    final highlights = ref.read(highlightProvider);
    final toDelete = highlights
        .where((h) => _selectedIds.contains(h.id))
        .toList();

    setState(() {
      _selectedIds.clear();
    });

    await ref.read(highlightProvider.notifier).removeHighlights(toDelete);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Highlights deleted')));
    }
  }

  Future<void> _addTagDialog(Highlight highlight) async {
    final controller = TextEditingController();
    final newTag = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'e.g., Methodology'),
            autofocus: true,
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newTag != null && newTag.trim().isNotEmpty) {
      final sanitizedTag = newTag.trim();
      if (!highlight.tags.contains(sanitizedTag)) {
        ref
            .read(highlightProvider.notifier)
            .updateHighlight(
              highlight.copyWith(tags: [...highlight.tags, sanitizedTag]),
            );
      }
    }
  }

  void _removeTag(Highlight highlight, String tag) {
    ref
        .read(highlightProvider.notifier)
        .updateHighlight(
          highlight.copyWith(
            tags: highlight.tags.where((t) => t != tag).toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final highlights = ref.watch(highlightProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIds.isNotEmpty
              ? '${_selectedIds.length} Selected'
              : 'Highlights',
        ),
        backgroundColor: _selectedIds.isNotEmpty
            ? AppColors.sageLight
            : AppColors.paperWhite,
        foregroundColor: AppColors.inkBlack,
        elevation: 1,
        actions: [
          if (_selectedIds.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelected,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selectedIds.clear()),
            ),
          ],
        ],
      ),
      body: highlights.isEmpty
          ? Center(
              child: Text(
                'No highlights saved yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: highlights.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final highlight = highlights[index];
                return _buildHighlightCard(context, ref, highlight);
              },
            ),
    );
  }

  Widget _buildHighlightCard(
    BuildContext context,
    WidgetRef ref,
    Highlight highlight,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedIds.contains(highlight.id);

    return InkWell(
      onLongPress: () => _toggleSelection(highlight.id),
      onTap: () async {
        if (_selectedIds.isNotEmpty) {
          _toggleSelection(highlight.id);
          return;
        }

        // Fetch the associated paper to open reader
        final asyncPapers = ref.read(dailyPapersProvider);

        final paper = asyncPapers.maybeWhen(
          data: (papers) => papers.firstWhere(
            (p) => p.id == highlight.paperId,
            orElse: () => _createFallbackPaper(highlight),
          ),
          orElse: () => _createFallbackPaper(highlight),
        );

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfReaderScreen(
                paper: paper,
                initialSearchText: highlight.textContent,
                initialPageNumber: highlight.pageNumber,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sageLight.withValues(alpha: 0.5)
              : AppColors.paperWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.sageDark : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: AppColors.inkBlack.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sageLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Saved',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.sageDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.sageDark),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${highlight.textContent}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: AppColors.inkBlack,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...highlight.tags.map(
                  (tag) => InputChip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.paperWhite,
                    deleteIconColor: AppColors.midGray,
                    onDeleted: () => _removeTag(highlight, tag),
                  ),
                ),
                ActionChip(
                  label: const Text('+ Tag', style: TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.sageLight,
                  onPressed: () => _addTagDialog(highlight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Paper _createFallbackPaper(Highlight highlight) {
    return Paper(
      id: highlight.paperId,
      title: 'Saved Paper',
      authors: [],
      source: PaperSource.community,
      sourceUrl: 'https://arxiv.org/pdf/${highlight.paperId}.pdf',
      publishedAt: DateTime.now(),
      topicTags: [],
      curiosityHook: '',
    );
  }
}
