import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/curiosity_card.dart';

class SampleCardsScreen extends StatelessWidget {
  const SampleCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock data for sample
    final mockPaper1 = Paper(
      id: '1',
      title: 'Attention Is All You Need',
      authors: ['Ashish Vaswani', 'Noam Shazeer'],
      source: PaperSource.arxiv,
      sourceUrl: '',
      publishedAt: DateTime(2017),
      topicTags: ['Machine Learning'],
      curiosityHook:
          'The dominant sequence transduction models are based on complex recurrent or convolutional neural networks that include an encoder and a decoder. The best performing models also connect the encoder and decoder through an attention mechanism.\n\nBut what if we dispense with recurrence and convolutions entirely?',
    );

    final mockPaper2 = Paper(
      id: '2',
      title:
          'Dopamine reward prediction-error signalling: a two-component response',
      authors: ['Wolfram Schultz'],
      source: PaperSource.semantic_scholar,
      sourceUrl: '',
      publishedAt: DateTime(2016),
      topicTags: ['Neuroscience'],
      curiosityHook:
          'For decades, we thought dopamine was simply the "pleasure" chemical. But looking closer at the specific timing of neuron firing reveals something far more interesting: a two-part response that calculates exactly how wrong our expectations were.\n\nHow does the brain mathematically compute a surprise?',
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Here\'s a taste', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Real papers. Real curiosity.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.midGray,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 24),
                        child: Transform.scale(
                          scale: 0.95,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.5,
                              child: CuriosityCard(paper: mockPaper2),
                            ),
                          ),
                        ),
                      ),
                      CuriosityCard(
                        paper: mockPaper1,
                        onReadFullTap: () {
                          // No-op for sample
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ElevatedButton(
                  onPressed: () => context.push('/onboarding/account'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('This is my kind of reading →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
