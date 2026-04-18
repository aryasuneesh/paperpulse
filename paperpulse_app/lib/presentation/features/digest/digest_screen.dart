import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/curiosity_card.dart';
import '../library/providers/bookmark_provider.dart';
import 'paper_detail_modal.dart';
import 'providers/digest_stack_provider.dart';
import 'providers/streak_provider.dart';
import 'share_card_sheet.dart';
import 'widgets/streak_popup.dart';

class DigestScreen extends ConsumerWidget {
  const DigestScreen({super.key});

  Future<void> _onSwipe(
    BuildContext context,
    WidgetRef ref,
    bool isRight,
    int maxPapers,
  ) async {
    final currentIndex = ref.read(digestStackProvider).currentIndex;
    if (currentIndex < maxPapers) {
      if (isRight) {
        final currentPaper =
            ref.read(digestStackProvider).papers[currentIndex];
        final bookmarkNotifier = ref.read(bookmarkProvider.notifier);

        Future.delayed(const Duration(milliseconds: 250), () {
          bookmarkNotifier.toggleBookmark(currentPaper);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Saved to Library',
                  style: TextStyle(color: AppColors.inkBlack),
                ),
                backgroundColor: AppColors.sageGreen,
                duration: Duration(seconds: 1),
              ),
            );
          }
        });
      }
      ref.read(digestStackProvider.notifier).swipeCard();
      final didIncrement =
          await ref.read(streakProvider.notifier).markActivity();
      if (context.mounted && didIncrement) {
        await StreakPopup.show(context, ref.read(streakProvider));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final digestState = ref.watch(digestStackProvider);
    final papers = digestState.papers;
    final currentIndex = digestState.currentIndex;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _buildTopBar(theme, ref),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDigestHeader(theme, papers.length),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildMainContent(
                context,
                theme,
                ref,
                digestState,
                papers,
                currentIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    DigestStackState state,
    List<Paper> papers,
    int currentIndex,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.sageGreen),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.midGray,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load daily papers',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.midGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (currentIndex >= papers.length) {
      return _buildEmptyState(theme, ref);
    }

    return Stack(
      children: [
        _buildCardStack(context, ref, papers, currentIndex),
        if (currentIndex == 0) // First-time tutorial overlay
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inkBlack.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      '← Skip',
                      style: TextStyle(
                        color: AppColors.paperWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Save →',
                      style: TextStyle(
                        color: AppColors.inkBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopBar(ThemeData theme, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final streakLabel = streak > 0 ? '$streak-day streak' : 'Start a streak!';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'DreamOrphans',
              fontSize: 26,
            ),
            children: [
              TextSpan(
                text: 'Paper',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.paperWhite
                      : AppColors.inkBlack,
                ),
              ),
              const TextSpan(
                text: 'Pulse',
                style: TextStyle(color: AppColors.sageGreen),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.sageLight,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                streakLabel,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: AppColors.sageDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDigestHeader(ThemeData theme, int totalPapers) {
    final now = DateTime.now();
    const days = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
      'FRIDAY', 'SATURDAY', 'SUNDAY',
    ];
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    final headerDate = '$dayName DIGEST · $monthName ${now.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          headerDate,
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: 'JetBrains Mono',
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'This Week in Research',
          style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          '$totalPapers papers curated for your interests',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
        ),
      ],
    );
  }

  Widget _buildCardStack(
    BuildContext context,
    WidgetRef ref,
    List<Paper> papers,
    int currentIndex,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final remainingPapers = papers.sublist(currentIndex);

        return Stack(
          alignment: Alignment.topCenter,
          children: remainingPapers
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key; // 0 is top, 1 is next, etc.
                final paper = entry.value;

                // Only show top two layers for performance and aesthetics
                if (index > 2) return const SizedBox();

                final verticalOffset = index * 24.0;
                final isTop = index == 0;
                final scale = 1.0 - (index * 0.05);

                final cardWidget = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Transform.translate(
                    offset: Offset(0, verticalOffset),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: IgnorePointer(
                        ignoring: !isTop,
                        child: Opacity(
                          opacity: 1.0 - (index * 0.3),
                          child: CuriosityCard(
                            paper: paper,
                            onReadFullTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    PaperDetailModal(paper: paper),
                              );
                            },
                            onBookmarkTap: isTop
                                ? () => _onSwipe(
                                    context,
                                    ref,
                                    true,
                                    papers.length,
                                  )
                                : null,
                            onShareTap: isTop
                                ? () => ShareCardSheet.show(context, paper)
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                if (isTop) {
                  return Dismissible(
                    key: ValueKey(paper.id),
                    onDismissed: (direction) {
                      _onSwipe(
                        context,
                        ref,
                        direction == DismissDirection.startToEnd,
                        papers.length,
                      );
                    },
                    child: cardWidget,
                  );
                }

                return cardWidget;
              })
              .toList()
              .reversed
              .toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check, size: 40, color: AppColors.sageDark),
          ),
        ),
        const SizedBox(height: 24),
        Text('You\'re all caught up.', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Your next digest lands Monday morning.\nBrowse in the meantime.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            // For testing purposes during MVP, let's allow resetting the stack
            ref.read(digestStackProvider.notifier).resetStack();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.paperWhite,
            foregroundColor: AppColors.inkBlack,
            side: const BorderSide(color: AppColors.lightGray),
            elevation: 0,
          ),
          child: const Text('Read Again (Demo)'),
        ),
      ],
    );
  }
}
