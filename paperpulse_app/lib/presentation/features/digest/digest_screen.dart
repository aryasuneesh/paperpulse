import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/curiosity_card.dart';
import 'providers/digest_stack_provider.dart';

class DigestScreen extends ConsumerWidget {
  const DigestScreen({super.key});

  void _onSwipe(
    BuildContext context,
    WidgetRef ref,
    bool isRight,
    int maxPapers,
  ) {
    if (ref.read(digestStackProvider).currentIndex < maxPapers) {
      if (isRight) {
        // Handle bookmark
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
      ref.read(digestStackProvider.notifier).swipeCard();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final digestState = ref.watch(digestStackProvider);
    final _papers = digestState.papers;
    final _currentIndex = digestState.currentIndex;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _buildTopBar(theme),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDigestHeader(theme, _papers.length),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _currentIndex >= _papers.length
                  ? _buildEmptyState(theme, ref)
                  : _buildCardStack(context, ref, _papers, _currentIndex),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Instrument Serif',
              fontSize: 22,
            ),
            children: const [
              TextSpan(
                text: 'Paper',
                style: TextStyle(color: AppColors.inkBlack),
              ),
              TextSpan(
                text: 'Pulse',
                style: TextStyle(
                  color: AppColors.sageDark,
                  fontStyle: FontStyle.italic,
                ),
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
          child: const Row(
            children: [
              Text('🔥', style: TextStyle(fontSize: 12)),
              SizedBox(width: 4),
              Text(
                '12-day streak',
                style: TextStyle(
                  fontFamily: 'Geist Mono',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          'MONDAY DIGEST · FEB 17',
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: 'Geist Mono',
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
    List<Paper> _papers,
    int _currentIndex,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final remainingPapers = _papers.sublist(_currentIndex);

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
                            onBookmarkTap: isTop
                                ? () => _onSwipe(
                                    context,
                                    ref,
                                    true,
                                    _papers.length,
                                  )
                                : null,
                            onShareTap: isTop
                                ? () {
                                    // TODO: Implement share
                                  }
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
                        _papers.length,
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
