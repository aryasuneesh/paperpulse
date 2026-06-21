import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/curiosity_card.dart';
import '../library/providers/bookmark_provider.dart';
import 'paper_detail_modal.dart';
import '../../../data/providers/papers_provider.dart';
import 'providers/digest_stack_provider.dart';
import 'providers/personalized_digest_provider.dart';
import 'providers/streak_provider.dart';
import 'share_card_sheet.dart';
import 'widgets/streak_popup.dart';
import '../../common_widgets/web_page_shell.dart';

const _digestTutorialSeenKey = 'paperpulse_digest_tutorial_seen';

final digestTutorialSeenProvider =
    NotifierProvider<DigestTutorialSeenNotifier, bool>(
      DigestTutorialSeenNotifier.new,
    );

class DigestTutorialSeenNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_digestTutorialSeenKey) ?? false;
  }

  Future<void> markSeen() async {
    if (state) return;
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_digestTutorialSeenKey, true);
  }
}

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

        final messenger = ScaffoldMessenger.of(context);
        Future.delayed(const Duration(milliseconds: 250), () {
          bookmarkNotifier.toggleBookmark(currentPaper);
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Saved to Library',
                style: TextStyle(color: AppColors.inkBlack),
              ),
              backgroundColor: AppColors.sageGreen,
              duration: Duration(seconds: 1),
            ),
          );
        });
      }
      ref.read(digestStackProvider.notifier).swipeCard();
      ref.read(digestTutorialSeenProvider.notifier).markSeen();
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
        child: WebPageShell(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: _buildTopBar(context, theme, ref),
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
        if (currentIndex == 0 && !ref.watch(digestTutorialSeenProvider))
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

  Widget _buildTopBar(BuildContext context, ThemeData theme, WidgetRef ref) {
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
        Row(
          children: [
            _RefreshButton(onPressed: () => _onRefresh(context, ref)),
            const SizedBox(width: 8),
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
        ),
      ],
    );
  }

  Future<void> _onRefresh(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(papersProvider.notifier).refresh();
    // Re-snapshot the digest stack so the user sees the new papers immediately.
    ref.read(digestStackProvider.notifier).reload();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Digest refreshed'),
        backgroundColor: AppColors.sageGreen,
        duration: Duration(seconds: 1),
      ),
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
    final mode = ref.watch(digestStackProvider).mode;
    final extendedAsync = ref.watch(extendedDigestProvider);
    final extendedCount = extendedAsync.asData?.value.length ?? 0;
    final inExtended = mode == DigestMode.extended;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.sageLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check, size: 40, color: AppColors.sageDark),
            ),
          ),
          const SizedBox(height: 24),
          Text('All done!', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            inExtended
                ? 'You\'ve seen everything we have for today.\nYour next digest lands soon.'
                : extendedCount > 0
                    ? 'Want to dig deeper into your interests?'
                    : 'Your next digest lands soon.\nCheck back tomorrow.',
            style:
                theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (!inExtended && extendedCount > 0)
            ElevatedButton(
              onPressed: () =>
                  ref.read(digestStackProvider.notifier).showExtended(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageGreen,
                foregroundColor: AppColors.inkBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                elevation: 0,
              ),
              child: Text('See $extendedCount more papers →'),
            ),
        ],
      ),
    );
  }
}

/// Compact refresh affordance in the digest top bar. Forces a fresh fetch
/// from HuggingFace — the escape hatch when the auto-freshness logic in
/// [PapersNotifier] hasn't fired yet (e.g. HF drops today's batch mid-session).
class _RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RefreshButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.refresh,
            size: 20,
            color: AppColors.sageDark,
          ),
        ),
      ),
    );
  }
}
