import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../main.dart' show sharedPrefs;
import '../../../../data/models/highlight.dart';

final highlightProvider = NotifierProvider<HighlightNotifier, List<Highlight>>(
  HighlightNotifier.new,
);

class HighlightNotifier extends Notifier<List<Highlight>> {
  static const _prefsKey = 'paperpulse_highlights';

  // Serializes concurrent PDF mutations per paper — prevents last-write-wins corruption
  final Map<String, Future<void>> _pdfMutationQueue = {};

  @override
  List<Highlight> build() {
    return _loadHighlights();
  }

  List<Highlight> _loadHighlights() {
    try {
      final String? data = sharedPrefs.getString(_prefsKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        return jsonList.map((e) => Highlight.fromJson(e)).toList();
      }
    } catch (e, st) {
      debugPrint('Highlight load error: $e\n$st');
    }
    return [];
  }

  void _saveHighlights(List<Highlight> highlights) {
    try {
      final String data = jsonEncode(
        highlights.map((e) => e.toJson()).toList(),
      );
      sharedPrefs.setString(_prefsKey, data);
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

    // Group by paperId to minimize file I/O
    final Map<String, List<Highlight>> paperDeletions = {};
    for (final h in highlightsToRemove) {
      paperDeletions.putIfAbsent(h.paperId, () => []).add(h);
    }

    // Chain mutations per paper — prevents concurrent writes corrupting the same PDF
    for (final entry in paperDeletions.entries) {
      final paperId = entry.key;
      final highlights = entry.value;
      _pdfMutationQueue[paperId] =
          (_pdfMutationQueue[paperId] ?? Future<void>.value())
              .then((_) => _removeAnnotationsFromPdf(paperId, highlights));
    }

    // Await this call's mutations before returning
    await Future.wait(
      paperDeletions.keys.map((id) => _pdfMutationQueue[id]!),
    );
  }

  Future<void> _removeAnnotationsFromPdf(
    String paperId,
    List<Highlight> highlights,
  ) async {
    try {
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
        // Fix: Future() instead of compute() — PdfDocument wraps a native object
        // and cannot be serialized across Dart isolate boundaries
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
