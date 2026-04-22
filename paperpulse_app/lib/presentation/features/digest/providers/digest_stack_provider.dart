import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/paper.dart';
import 'personalized_digest_provider.dart';

enum DigestMode { main, extended }

final digestStackProvider =
    NotifierProvider<DigestStackNotifier, DigestStackState>(
      DigestStackNotifier.new,
    );

class DigestStackState {
  final List<Paper> papers;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final DigestMode mode;

  DigestStackState({
    required this.papers,
    required this.currentIndex,
    this.isLoading = false,
    this.error,
    this.mode = DigestMode.main,
  });

  DigestStackState copyWith({
    List<Paper>? papers,
    int? currentIndex,
    bool? isLoading,
    String? error,
    DigestMode? mode,
  }) {
    return DigestStackState(
      papers: papers ?? this.papers,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      mode: mode ?? this.mode,
    );
  }
}

class DigestStackNotifier extends Notifier<DigestStackState> {
  bool _disposed = false;
  bool _initialLoaded = false;

  @override
  DigestStackState build() {
    ref.onDispose(() => _disposed = true);

    // ref.listen — not watch — so bookmark-triggered rebuilds of
    // personalizedDigestProvider don't cause build() to rerun and reset state.
    ref.listen<AsyncValue<List<Paper>>>(
      personalizedDigestProvider,
      (prev, next) {
        if (_disposed) return;
        next.when(
          loading: () {},
          error: (e, _) =>
              state = state.copyWith(isLoading: false, error: e.toString()),
          data: (papers) {
            if (!_initialLoaded && state.mode == DigestMode.main) {
              _initialLoaded = true;
              state = state.copyWith(
                papers: papers,
                isLoading: false,
                error: null,
              );
            } else if (state.isLoading) {
              state = state.copyWith(isLoading: false, error: null);
            }
          },
        );
      },
      fireImmediately: true,
    );

    final initial = ref.read(personalizedDigestProvider);
    final initialPapers = initial.asData?.value ?? const <Paper>[];
    if (initialPapers.isNotEmpty) _initialLoaded = true;
    return DigestStackState(
      papers: initialPapers,
      currentIndex: 0,
      isLoading: initial.isLoading,
      error: initial.hasError ? initial.error.toString() : null,
    );
  }

  void swipeCard() {
    if (state.currentIndex < state.papers.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void showExtended() {
    final extended = ref.read(extendedDigestProvider).asData?.value ?? const [];
    state = state.copyWith(
      papers: extended,
      currentIndex: 0,
      mode: DigestMode.extended,
    );
  }

  void resetStack() {
    state = state.copyWith(currentIndex: 0);
  }
}
