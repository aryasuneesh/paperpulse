import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/highlight.dart';
import '../../../data/models/paper.dart';
import '../library/providers/highlight_provider.dart';

class PdfReaderScreen extends ConsumerStatefulWidget {
  const PdfReaderScreen({
    required this.paper,
    this.initialSearchText,
    this.initialPageNumber,
    super.key,
  });

  final Paper paper;
  final String? initialSearchText;
  final int? initialPageNumber;

  @override
  ConsumerState<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends ConsumerState<PdfReaderScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  String? _selectedText;

  File? _localPdfFile;
  bool _isLoadingPdf = true;

  @override
  void initState() {
    super.initState();
    _initLocalFile();
  }

  Future<void> _initLocalFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/paper_${widget.paper.id}.pdf');
      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _localPdfFile = file;
            _isLoadingPdf = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPdf = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPdf = false);
    }
  }

  void _onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    if (details.selectedText != null &&
        details.selectedText!.trim().isNotEmpty) {
      // Decode the text using runes to automatically strip out unpaired and malformed UTF-16 surrogate pairs from the Syncfusion PDF OCR extraction, resolving the jsonEncode crash
      _selectedText = String.fromCharCodes(details.selectedText!.runes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paperWhite,
        foregroundColor: AppColors.inkBlack,
        elevation: 1,
        title: Text(
          widget.paper.title,
          style: const TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: AppColors.sageGreen.withValues(alpha: 0.5),
            selectionHandleColor: AppColors.sageDark,
          ),
        ),
        child: _isLoadingPdf
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.sageGreen),
              )
            : (_localPdfFile != null
                  ? SfPdfViewer.file(
                      _localPdfFile!,
                      key: _pdfViewerKey,
                      controller: _pdfViewerController,
                      canShowScrollHead: false,
                      onDocumentLoaded:
                          (PdfDocumentLoadedDetails details) async {
                            if (widget.initialPageNumber != null) {
                              _pdfViewerController.jumpToPage(
                                widget.initialPageNumber!,
                              );
                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );
                            }
                            if (widget.initialSearchText != null) {
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              final sanitizedSearch = widget.initialSearchText!
                                  .replaceAll('\n', ' ')
                                  .replaceAll('\r', '')
                                  .trim();
                              _pdfViewerController.searchText(sanitizedSearch);
                            }
                          },
                      onTextSelectionChanged: _onTextSelectionChanged,
                      onAnnotationAdded: _handleAnnotationAdded,
                    )
                  : SfPdfViewer.network(
                      widget.paper.sourceUrl,
                      key: _pdfViewerKey,
                      controller: _pdfViewerController,
                      canShowScrollHead: false,
                      onDocumentLoaded:
                          (PdfDocumentLoadedDetails details) async {
                            if (widget.initialPageNumber != null) {
                              _pdfViewerController.jumpToPage(
                                widget.initialPageNumber!,
                              );
                              await Future.delayed(
                                const Duration(milliseconds: 300),
                              );
                            }
                            if (widget.initialSearchText != null) {
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              final sanitizedSearch = widget.initialSearchText!
                                  .replaceAll('\n', ' ')
                                  .replaceAll('\r', '')
                                  .trim();
                              _pdfViewerController.searchText(sanitizedSearch);
                            }
                          },
                      onTextSelectionChanged: _onTextSelectionChanged,
                      onAnnotationAdded: _handleAnnotationAdded,
                    )),
      ),
    );
  }

  void _handleAnnotationAdded(Annotation annotation) async {
    // We intercept natively created annotations and save the associated selected text
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      final highlightId = DateTime.now().millisecondsSinceEpoch.toString();
      annotation.name =
          highlightId; // Force the syncfusion internal native ID to perfectly match our UUID so we can locate it downstream

      final newHighlight = Highlight(
        id: highlightId,
        userId: 'user123',
        paperId: widget.paper.id,
        textContent: _selectedText!,
        color: '#A3B899', // Default brand color for saved highlights
        pageNumber: _pdfViewerController.pageNumber,
        annotationName: highlightId,
        createdAt: DateTime.now(),
      );

      ref.read(highlightProvider.notifier).addHighlight(newHighlight);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to Highlights!'),
          backgroundColor: AppColors.sageGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _selectedText = null);
    }

    // Persist the embedded PDF annotations to the local file system
    try {
      final List<int> bytes = await _pdfViewerController.saveDocument();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/paper_${widget.paper.id}.pdf');
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('Error saving PDF annotations: $e');
    }
  }
}
