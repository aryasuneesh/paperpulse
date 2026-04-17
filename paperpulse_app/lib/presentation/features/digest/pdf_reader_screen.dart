import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import '../../../data/models/highlight.dart';
import '../../../data/models/paper.dart';
import '../../../data/models/bookmark.dart';
import '../library/providers/bookmark_provider.dart';
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

  int _currentPage = 1;
  int _totalPages = 0;
  bool _showPageIndicator = false;
  Timer? _pageIndicatorTimer;

  @override
  void initState() {
    super.initState();
    _initLocalFile();
  }

  @override
  void dispose() {
    _pageIndicatorTimer?.cancel();
    super.dispose();
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
        if (mounted) setState(() => _isLoadingPdf = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPdf = false);
    }
  }

  void _onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    if (details.selectedText != null &&
        details.selectedText!.trim().isNotEmpty) {
      // Decode using runes to strip malformed UTF-16 surrogate pairs from
      // Syncfusion OCR extraction — prevents jsonEncode crash on invalid Unicode
      _selectedText = String.fromCharCodes(details.selectedText!.runes);
    }
  }

  Future<void> _onDocumentLoaded(PdfDocumentLoadedDetails details) async {
    setState(() => _totalPages = details.document.pages.count);
    if (widget.initialPageNumber != null) {
      _pdfViewerController.jumpToPage(widget.initialPageNumber!);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (widget.initialSearchText != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      final sanitized = widget.initialSearchText!
          .replaceAll('\n', ' ')
          .replaceAll('\r', '')
          .trim();
      _pdfViewerController.searchText(sanitized);
    }
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() => _currentPage = details.newPageNumber);
    _revealPageIndicator();
    _checkIfFinished(details.newPageNumber);
  }

  void _checkIfFinished(int page) {
    if (_totalPages > 0 && page >= _totalPages) {
      ref
          .read(bookmarkProvider.notifier)
          .updateStatus(widget.paper.id, BookmarkStatus.finished);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as Finished!'),
            backgroundColor: AppColors.sageGreen,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _revealPageIndicator() {
    setState(() => _showPageIndicator = true);
    _pageIndicatorTimer?.cancel();
    _pageIndicatorTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showPageIndicator = false);
    });
  }

  Widget _buildViewer() {
    final common = (SfPdfViewer viewer) => Listener(
          onPointerDown: (_) => _revealPageIndicator(),
          child: RepaintBoundary(child: viewer),
        );

    if (_localPdfFile != null) {
      return common(SfPdfViewer.file(
        _localPdfFile!,
        key: _pdfViewerKey,
        controller: _pdfViewerController,
        canShowScrollHead: false,
        enableHyperlinkNavigation: false,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        onTextSelectionChanged: _onTextSelectionChanged,
        onAnnotationAdded: _handleAnnotationAdded,
      ));
    }

    return common(SfPdfViewer.network(
      widget.paper.sourceUrl,
      key: _pdfViewerKey,
      controller: _pdfViewerController,
      canShowScrollHead: false,
      enableHyperlinkNavigation: false,
      onDocumentLoaded: _onDocumentLoaded,
      onPageChanged: _onPageChanged,
      onTextSelectionChanged: _onTextSelectionChanged,
      onAnnotationAdded: _handleAnnotationAdded,
    ));
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
            : Stack(
                children: [
                  _buildViewer(),
                  // Page number indicator
                  if (_totalPages > 0)
                    Positioned(
                      right: 16,
                      bottom: 24,
                      child: AnimatedOpacity(
                        opacity: _showPageIndicator ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inkBlack.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_currentPage / $_totalPages',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 12,
                              color: AppColors.paperWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _handleAnnotationAdded(Annotation annotation) async {
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      final highlightId = DateTime.now().millisecondsSinceEpoch.toString();
      // Force the Syncfusion internal annotation ID to match our ID
      // so we can locate it for deletion in highlight_provider
      annotation.name = highlightId;

      final newHighlight = Highlight(
        id: highlightId,
        userId: ref.read(currentUserIdProvider),
        paperId: widget.paper.id,
        textContent: _selectedText!,
        color: '#A3B899',
        pageNumber: _pdfViewerController.pageNumber,
        annotationName: highlightId,
        createdAt: DateTime.now(),
      );

      ref.read(highlightProvider.notifier).addHighlight(newHighlight);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to Highlights!'),
            backgroundColor: AppColors.sageGreen,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      setState(() => _selectedText = null);
    }

    // Persist embedded PDF annotations to the local file system
    try {
      final List<int> bytes = await _pdfViewerController.saveDocument();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/paper_${widget.paper.id}.pdf');
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('Error saving PDF annotations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save annotation to PDF'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
