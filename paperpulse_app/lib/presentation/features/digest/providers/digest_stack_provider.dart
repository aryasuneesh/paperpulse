import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/paper.dart';
import '../../../../data/repositories/paper_repository.dart';

final digestStackProvider =
    NotifierProvider<DigestStackNotifier, DigestStackState>(() {
      return DigestStackNotifier();
    });

class DigestStackState {
  final List<Paper> papers;
  final int currentIndex;

  final bool isLoading;
  final String? error;

  DigestStackState({
    required this.papers,
    required this.currentIndex,
    this.isLoading = false,
    this.error,
  });

  DigestStackState copyWith({
    List<Paper>? papers,
    int? currentIndex,
    bool? isLoading,
    String? error,
  }) {
    return DigestStackState(
      papers: papers ?? this.papers,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DigestStackNotifier extends Notifier<DigestStackState> {
  @override
  DigestStackState build() {
    // Initial state is loading
    _loadPapers();
    return DigestStackState(papers: [], currentIndex: 0, isLoading: true);
  }

  Future<void> _loadPapers() async {
    try {
      final repository = ref.read(paperRepositoryProvider);
      final papers = await repository.fetchDailyPapers();
      state = state.copyWith(papers: papers, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void swipeCard() {
    if (state.currentIndex < state.papers.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void resetStack() {
    state = state.copyWith(currentIndex: 0);
  }
}
