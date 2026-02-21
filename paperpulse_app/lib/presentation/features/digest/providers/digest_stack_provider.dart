import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/paper.dart';

final digestStackProvider =
    NotifierProvider<DigestStackNotifier, DigestStackState>(() {
      return DigestStackNotifier();
    });

class DigestStackState {
  final List<Paper> papers;
  final int currentIndex;

  DigestStackState({required this.papers, required this.currentIndex});

  DigestStackState copyWith({List<Paper>? papers, int? currentIndex}) {
    return DigestStackState(
      papers: papers ?? this.papers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class DigestStackNotifier extends Notifier<DigestStackState> {
  @override
  DigestStackState build() {
    return DigestStackState(papers: _mockPapers, currentIndex: 0);
  }

  void swipeCard() {
    if (state.currentIndex < state.papers.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void resetStack() {
    state = state.copyWith(currentIndex: 0);
  }

  static final List<Paper> _mockPapers = [
    Paper(
      id: '1',
      title: 'Attention Is All You Need',
      authors: ['Ashish Vaswani', 'Noam Shazeer'],
      source: PaperSource.arxiv,
      sourceUrl: '',
      publishedAt: DateTime(2017),
      topicTags: ['Machine Learning'],
      curiosityHook:
          'The dominant sequence transduction models are based on complex recurrent or convolutional neural networks that include an encoder and a decoder. The best performing models also connect the encoder and decoder through an attention mechanism.\n\nBut what if we dispense with recurrence and convolutions entirely?',
    ),
    Paper(
      id: '2',
      title: 'Dopamine reward prediction-error signalling',
      authors: ['Wolfram Schultz'],
      source: PaperSource.semantic_scholar,
      sourceUrl: '',
      publishedAt: DateTime(2016),
      topicTags: ['Neuroscience'],
      curiosityHook:
          'For decades, we thought dopamine was simply the "pleasure" chemical. But looking closer at the specific timing of neuron firing reveals something far more interesting: a two-part response that calculates exactly how wrong our expectations were.\n\nHow does the brain mathematically compute a surprise?',
    ),
    Paper(
      id: '3',
      title: 'The Unreasonable Effectiveness of Data',
      authors: ['Alon Halevy', 'Peter Norvig', 'Fernando Pereira'],
      source: PaperSource.ieee,
      sourceUrl: '',
      publishedAt: DateTime(2009),
      topicTags: ['Machine Learning'],
      curiosityHook:
          'In natural language processing, we spend enormous effort hand-crafting grammatical rules and complex models. Yet, simple models given massive amounts of data consistently outperform them.\n\nIs our pursuit of elegant algorithms actually holding us back?',
    ),
  ];
}
