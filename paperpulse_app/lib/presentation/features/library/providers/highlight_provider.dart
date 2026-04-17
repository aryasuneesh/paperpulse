import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../main.dart' show sharedPrefs;
import '../../../../core/providers/user_provider.dart';
import '../../../../data/models/highlight.dart';

final highlightProvider = NotifierProvider<HighlightNotifier, List<Highlight>>(
  HighlightNotifier.new,
);

class HighlightNotifier extends Notifier<List<Highlight>> {
  static const _prefsKey = 'paperpulse_highlights';

  final Map<String, Future<void>> _pdfMutationQueue = {};

  @override
  List<Highlight> build() {
    final currentUserId = ref.watch(currentUserIdProvider);
    return _loadHighlights(currentUserId);
  }

  List<Highlight> _loadHighlights(String currentUserId) {
    try {
      final String? data = sharedPrefs.getString(_prefsKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        return jsonList
            .whereType<Map<String, dynamic>>()
            .map((e) {
              try {
                return Highlight.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<Highlight>()
            .where((h) => h.userId == currentUserId)
            .toList();
      }
    } catch (e, st) {
      debugPrint('Highlight load error: $e\n$st');
    }
    return [];
  }

  void _saveHighlights(List<Highlight> highlights) {
    try {
      // Load ALL highlights (other users), replace only this user's entries
      final currentUserId = ref.read(currentUserIdProvider);
      List<Map<String, dynamic>> allHighlights = [];
      final String? existing = sharedPrefs.getString(_prefsKey);
      if (existing != null) {
        final decoded = jsonDecode(existing) as List;
        allHighlights = decoded
            .whereType<Map<String, dynamic>>()
            .where((e) => e['userId'] != currentUserId)
            .toList();
      }
      allHighlights.addAll(highlights.map((e) => e.toJson()));
      sharedPrefs.setString(_prefsKey, jsonEncode(allHighlights));
    } catch (e, st) {
      debugPrint('Failed to persist highlights: $e\n$st');
    }
  }

  void addHighlight(Highlight highlight) {
    state = [...state, highlight];
    _saveHighlights(state);
  }

  void updateHighlight(Highlight updatedHighlight) {
    state = [
      for (final h in state)
        if (h.id == updatedHighlight.id) updatedHighlight else h,
    ];
    _saveHighlights(state);
  }

  Future<void> removeHighlights(List<Highlight> highlightsToRemove) async {
    final idsToRemove = highlightsToRemove.map((h) => h.id).toSet();
    state = state.where((h) => !idsToRemove.contains(h.id)).toList();
    _saveHighlights(state);

    final Map<String, List<Highlight>> paperDeletions = {};
    for (final h in highlightsToRemove) {
      paperDeletions.putIfAbsent(h.paperId, () => []).add(h);
    }

    for (final entry in paperDeletions.entries) {
      final paperId = entry.key;
      final highlights = entry.value;
      _pdfMutationQueue[paperId] =
          (_pdfMutationQueue[paperId] ?? Future<void>.value())
              .then((_) => _removeAnnotationsFromPdf(paperId, highlights));
    }

    await Future.wait(
      paperDeletions.keys.map((id) => _pdfMutationQueue[id]!),
    );
  }

  Future<void> _removeAnnotationsFromPdf(
    String paperId,
    List<Highlight> highlights,
  ) async {
    try {
      // Reject paperIds that could escape the documents directory via path traversal.
      if (!RegExp(r'^[a-zA-Z0-9.\-]+$').hasMatch(paperId)) return;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/paper_$paperId.pdf');
      if (!await file.exists()) return;

      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      bool modified = false;

      for (final highlight in highlights) {
        if (highlight.pageNumber != null &&
            highlight.pageNumber! > 0 &&
            highlight.pageNumber! <= document.pages.count) {
          final PdfPage page = document.pages[highlight.pageNumber! - 1];
          for (int i = page.annotations.count - 1; i >= 0; i--) {
            final PdfAnnotation pdfAnnotation = page.annotations[i];
            if (pdfAnnotation is PdfTextMarkupAnnotation &&
                pdfAnnotation.text == highlight.annotationName) {
              page.annotations.remove(pdfAnnotation);
              modified = true;
              break;
            }
          }
        }
      }

      if (modified) {
        final List<int> savedBytes = await Future(() => document.saveSync());
        await file.writeAsBytes(savedBytes, flush: true);
      }
      document.dispose();
    } catch (e, st) {
      debugPrint('Error removing annotation from PDF: $e\n$st');
    }
  }

  List<Highlight> getHighlightsForPaper(String paperId) {
    return state.where((h) => h.paperId == paperId).toList();
  }
}
