import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/paper.dart';
import '../../../../data/providers/papers_provider.dart';

final digestStackProvider =
    NotifierProvider<DigestStackNotifier, DigestStackState>(
      DigestStackNotifier.new,
    );

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
  bool _disposed = false;

  @override
  DigestStackState build() {
    ref.onDispose(() => _disposed = true);

    // Listen to the shared cached provider
    final papersAsync = ref.watch(papersProvider);
    papersAsync.when(
      loading: () {},
      error: (e, _) {
        if (!_disposed) {
          state = state.copyWith(isLoading: false, error: e.toString());
        }
      },
      data: (papers) {
        if (!_disposed) {
          state = state.copyWith(papers: papers, isLoading: false, error: null);
        }
      },
    );

    return DigestStackState(
      papers: papersAsync.valueOrNull ?? [],
      currentIndex: 0,
      isLoading: papersAsync.isLoading,
      error: papersAsync.hasError ? papersAsync.error.toString() : null,
    );
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
