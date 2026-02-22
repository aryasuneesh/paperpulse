import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../main.dart'; // To access global sharedPrefs
import '../../../../data/models/highlight.dart';

final highlightProvider = NotifierProvider<HighlightNotifier, List<Highlight>>(
  () {
    return HighlightNotifier();
  },
);

class HighlightNotifier extends Notifier<List<Highlight>> {
  static const _prefsKey = 'paperpulse_highlights';

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
    } catch (e) {
      debugPrint('Highlight Load Error: $e');
    }
    return [];
  }

  void _saveHighlights(List<Highlight> highlights) {
    try {
      final String data = jsonEncode(
        highlights.map((e) => e.toJson()).toList(),
      );
      sharedPrefs.setString(_prefsKey, data);
    } catch (_) {}
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

    // Group deletions by paperId to minimize file I/O operations
    final Map<String, List<Highlight>> paperDeletions = {};
    for (final h in highlightsToRemove) {
      paperDeletions.putIfAbsent(h.paperId, () => []).add(h);
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      for (final entry in paperDeletions.entries) {
        final paperId = entry.key;
        final highlights = entry.value;

        final file = File('${dir.path}/paper_$paperId.pdf');
        if (await file.exists()) {
          final List<int> bytes = await file.readAsBytes();
          final PdfDocument document = PdfDocument(inputBytes: bytes);
          bool modified = false;

          for (final highlight in highlights) {
            if (highlight.pageNumber != null &&
                highlight.pageNumber! > 0 &&
                highlight.pageNumber! <= document.pages.count) {
              final PdfPage page = document.pages[highlight.pageNumber! - 1];

              // Backward traversal since we are removing items
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
            final List<int> savedBytes = await compute<PdfDocument, List<int>>(
              (PdfDocument doc) => doc.saveSync(),
              document,
            );
            await file.writeAsBytes(savedBytes, flush: true);
          }
          document.dispose();
        }
      }
    } catch (e) {
      debugPrint('Error removing annotation from PDF: $e');
    }
  }

  List<Highlight> getHighlightsForPaper(String paperId) {
    return state.where((h) => h.paperId == paperId).toList();
  }
}
