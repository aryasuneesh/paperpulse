import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/highlight.dart';
import '../../../data/models/paper.dart';
import '../library/providers/highlight_provider.dart';

class HtmlReaderScreen extends ConsumerStatefulWidget {
  const HtmlReaderScreen({
    required this.paper,
    this.initialSearchText,
    super.key,
  });

  final Paper paper;
  final String? initialSearchText;

  @override
  ConsumerState<HtmlReaderScreen> createState() => _HtmlReaderScreenState();
}

class _HtmlReaderScreenState extends ConsumerState<HtmlReaderScreen> {
  InAppWebViewController? _controller;
  int _fontSize = 16;
  SharedPreferences? _prefs;

  String? _pendingSelection;
  String? _pendingSentence;

  static const _fontSizeKey = 'paperpulse_html_font_size';
  static const _minFontSize = 12;
  static const _maxFontSize = 24;
  static const _fontSizeStep = 2;

  static const List<String> _highlightColors = [
    '#A3B899',
    '#F9C74F',
    '#F4A261',
    '#E76F51',
    '#457B9D',
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _prefs?.setInt(_fontSizeKey, _fontSize);
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fontSize = _prefs?.getInt(_fontSizeKey) ?? 16;
    });
  }

  String get _htmlUrl {
    final url = widget.paper.sourceUrl;
    final html = url.replaceAllMapped(
      RegExp(r'pdf/(.*)\.pdf$'),
      (m) => 'html/${m[1]}',
    );
    assert(html != url, 'HtmlReaderScreen opened with non-ArXiv URL: $url');
    return html;
  }

  Future<void> _applyFontSize() async {
    await _controller?.evaluateJavascript(
      source:
          "document.body.style.fontSize='${_fontSize}px';"
          "document.body.style.lineHeight='1.6';",
    );
  }

  void _changeFontSize(int delta) {
    final next = _fontSize + delta;
    if (next < _minFontSize || next > _maxFontSize) return;
    setState(() => _fontSize = next);
    _prefs?.setInt(_fontSizeKey, _fontSize);
    _applyFontSize();
  }

  Future<void> _onPageLoaded() async {
    if (!mounted) return;
    await _applyFontSize();
    if (!mounted) return;

    await _controller?.evaluateJavascript(source: '''
(function() {
  var _selTimer;
  document.addEventListener('selectionchange', function() {
    clearTimeout(_selTimer);
    _selTimer = setTimeout(function() {
      const sel = window.getSelection();
      const text = sel ? sel.toString().trim() : '';
      if (text.length > 0) {
        let sentence = text;
        try {
          const range = sel.getRangeAt(0);
          const node = range.startContainer;
          sentence = (node.textContent || text).trim().substring(0, 500);
        } catch(e) {}
        window.flutter_inappwebview.callHandler('SelectionHandler', {text: text, sentence: sentence});
      }
    }, 300);
  });
})();
''');

    if (!mounted) return;

    await _controller?.evaluateJavascript(source: '''
function highlightText(text, color) {
  if (!text) return;
  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
  let node;
  while (node = walker.nextNode()) {
    const idx = node.nodeValue.indexOf(text);
    if (idx >= 0) {
      const mark = document.createElement('mark');
      mark.style.background = color;
      mark.style.color = 'inherit';
      const after = node.splitText(idx);
      after.splitText(text.length);
      const clone = after.cloneNode(true);
      mark.appendChild(clone);
      after.parentNode.replaceChild(mark, after);
      break;
    }
  }
}
''');

    if (!mounted) return;

    final highlights = ref.read(highlightProvider).where(
          (h) => h.paperId == widget.paper.id && h.readerType == 'html',
        );
    for (final h in highlights) {
      final color = _hexToRgba(h.color, 0.4);
      if (color == null) continue;
      await _controller?.evaluateJavascript(
        source: "highlightText(${jsonEncode(h.textContent)}, ${jsonEncode(color)});",
      );
      if (!mounted) return;
    }

    if (!mounted) return;

    if (widget.initialSearchText != null) {
      await _controller?.evaluateJavascript(source: '''
(function() {
  const target = ${jsonEncode(widget.initialSearchText)};
  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
  let node;
  while (node = walker.nextNode()) {
    if (node.nodeValue.indexOf(target) >= 0) {
      node.parentElement && node.parentElement.scrollIntoView({behavior: 'smooth', block: 'center'});
      break;
    }
  }
})();
''');
    }
  }

  // Returns null for malformed hex colors to skip injection safely.
  String? _hexToRgba(String hex, double alpha) {
    try {
      final h = hex.replaceFirst('#', '');
      if (h.length != 6) return null;
      final r = int.parse(h.substring(0, 2), radix: 16);
      final g = int.parse(h.substring(2, 4), radix: 16);
      final b = int.parse(h.substring(4, 6), radix: 16);
      return 'rgba($r, $g, $b, $alpha)';
    } catch (_) {
      return null;
    }
  }

  void _showColorPicker(BuildContext context) {
    if (_pendingSelection == null) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paperWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Highlight colour',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _highlightColors.map((hexColor) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _saveHighlight(hexColor);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _colorFromHex(hexColor),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.lightGray,
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Color _colorFromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  Future<void> _saveHighlight(String selectedHexColor) async {
    if (_pendingSelection == null) return;
    if (!mounted) return;

    final selection = _pendingSelection!;
    final sentence = _pendingSentence;

    final h = Highlight(
      id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}',
      userId: ref.read(currentUserIdProvider),
      paperId: widget.paper.id,
      textContent: selection,
      color: selectedHexColor,
      annotationName: '',
      readerType: 'html',
      searchText: sentence,
      createdAt: DateTime.now(),
    );
    ref.read(highlightProvider.notifier).addHighlight(h);

    final rgba = _hexToRgba(selectedHexColor, 0.4);
    if (rgba != null) {
      await _controller?.evaluateJavascript(
        source: "highlightText(${jsonEncode(selection)}, ${jsonEncode(rgba)});",
      );
    }

    if (!mounted) return;

    setState(() {
      _pendingSelection = null;
      _pendingSentence = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to Highlights!'),
        backgroundColor: AppColors.sageGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
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
          style: const TextStyle(
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Decrease font size',
            onPressed: _fontSize > _minFontSize
                ? () => _changeFontSize(-_fontSizeStep)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'Increase font size',
            onPressed: _fontSize < _maxFontSize
                ? () => _changeFontSize(_fontSizeStep)
                : null,
          ),
          Opacity(
            opacity: _pendingSelection != null ? 1.0 : 0.35,
            child: IconButton(
              icon: const Icon(Icons.highlight),
              tooltip: 'Highlight selected text',
              onPressed: _pendingSelection != null
                  ? () => _showColorPicker(context)
                  : null,
            ),
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_htmlUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          supportZoom: true,
          useWideViewPort: true,
          loadWithOverviewMode: true,
        ),
        onWebViewCreated: (controller) {
          _controller = controller;
          controller.addJavaScriptHandler(
            handlerName: 'SelectionHandler',
            callback: (args) {
              if (args.isNotEmpty) {
                final data = args.first as Map<String, dynamic>;
                final text = data['text'] as String? ?? '';
                final sentence = data['sentence'] as String? ?? text;
                if (text.trim().isNotEmpty) {
                  _pendingSelection = text;
                  _pendingSentence = sentence;
                  if (mounted) setState(() {});
                }
              }
            },
          );
        },
        onLoadStop: (controller, url) async {
          await _onPageLoaded();
        },
      ),
    );
  }
}
