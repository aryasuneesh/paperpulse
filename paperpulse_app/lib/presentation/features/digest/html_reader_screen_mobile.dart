import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
  int _fontSize = 16;
  SharedPreferences? _prefs;
  String? _pendingSelection;
  String? _pendingSentence;
  Rect? _pillRect;
  String? _pillText;
  String? _pillSentence;

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

  static const _kAnnotationTypes = <(String, IconData, String)>[
    ('highlight', Icons.highlight, 'Highlight'),
    ('underline', Icons.format_underline, 'Underline'),
    ('strikethrough', Icons.strikethrough_s, 'Strike'),
    ('squiggly', Icons.waves, 'Squiggly'),
  ];

  String get _htmlUrl {
    final url = widget.paper.sourceUrl;
    final html = url.replaceAllMapped(
      RegExp(r'pdf/(.*)\.pdf$'),
      (m) => 'html/${m[1]}',
    );
    assert(html != url, 'HtmlReaderScreen opened with non-ArXiv URL: $url');
    return html;
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _onPageLoaded(),
      ))
      ..addJavaScriptChannel(
        'ClipboardHandler',
        onMessageReceived: (msg) async {
          await Clipboard.setData(ClipboardData(text: msg.message));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied!'),
                backgroundColor: AppColors.sageGreen,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
      )
      ..addJavaScriptChannel(
        'SelectionHandler',
        onMessageReceived: (msg) {
          try {
            final data = jsonDecode(msg.message) as Map<String, dynamic>;
            final action = data['action'] as String? ?? '';
            if (action == 'show_pill') {
              final text = data['text'] as String? ?? '';
              final sentence = data['sentence'] as String? ?? text;
              if (text.isNotEmpty && mounted) {
                setState(() {
                  _pillText = text;
                  _pillSentence = sentence;
                  _pillRect = Rect.zero; // non-null sentinel; position is fixed bottom-centre
                });
              }
            } else if (action == 'hide_pill') {
              if (mounted && _pillRect != null) setState(() { _pillRect = null; });
            }
          } catch (_) {}
        },
      )
      ..loadRequest(Uri.parse(_htmlUrl));
  }

  @override
  void dispose() {
    _prefs?.setInt(_fontSizeKey, _fontSize);
    super.dispose();
  }

  void _onCopyTap() async {
    if (_pillText == null) return;
    final text = _pillText!;
    if (mounted) setState(() { _pillRect = null; _pillText = null; _pillSentence = null; });
    await _controller.runJavaScript("window.getSelection()?.removeAllRanges?.()");
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Copied!'),
        backgroundColor: AppColors.sageGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ));
    }
  }

  void _onHighlightTap() {
    if (_pillText == null) return;
    _pendingSelection = _pillText;
    _pendingSentence = _pillSentence;
    if (mounted) setState(() { _pillRect = null; });
    _showAnnotationPicker(context);
  }

  Widget _buildPillOverlay() {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x1F000000)),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pillButton('Copy', const Color(0xFF222222), rightBorder: true, onTap: _onCopyTap),
              _pillButton('✦ Highlight', const Color(0xFF3a5a40), rightBorder: false, onTap: _onHighlightTap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillButton(String label, Color color, {required bool rightBorder, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: rightBorder
            ? const BoxDecoration(border: Border(right: BorderSide(color: Color(0x1A000000))))
            : null,
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fontSize = _prefs?.getInt(_fontSizeKey) ?? 16;
    });
  }

  Future<void> _applyFontSize() async {
    // setProperty with 'important' sets an inline !important — the single
    // highest-priority slot in CSS, beating any author or external stylesheet.
    await _controller.runJavaScript('''
(function() {
  var size = '${_fontSize}px';
  var body = document.body;
  if (!body) return;
  body.style.setProperty('font-size', size, 'important');
  body.style.setProperty('line-height', '1.6', 'important');
  var textSels = 'p,li,td,th,dt,dd,figcaption,blockquote,.ltx_p,.ltx_para,.ltx_text,.ltx_item';
  document.querySelectorAll(textSels).forEach(function(el) {
    el.style.setProperty('font-size', size, 'important');
    el.style.setProperty('line-height', '1.6', 'important');
  });
  var headings = [['h1,.ltx_title', 1.8], ['h2', 1.5], ['h3', 1.3], ['h4,h5,h6', 1.1]];
  headings.forEach(function(pair) {
    document.querySelectorAll(pair[0]).forEach(function(el) {
      el.style.setProperty('font-size', (${_fontSize} * pair[1]) + 'px', 'important');
    });
  });
})();
''');
  }

  void _changeFontSize(int delta) {
    final next = _fontSize + delta;
    if (next < _minFontSize || next > _maxFontSize) return;
    setState(() => _fontSize = next);
    _prefs?.setInt(_fontSizeKey, _fontSize);
    _applyFontSize();
  }

  Future<void> _injectSelectionStyles() async {
    await _controller.runJavaScript(r'''
(function() {
  if (document.getElementById('_pp_sel_style')) return;
  var s = document.createElement('style');
  s.id = '_pp_sel_style';
  s.textContent =
    'body,body *{-webkit-user-select:text;user-select:text;}' +
    '::selection{background:rgba(163,184,153,0.35);}';
  document.head.appendChild(s);
})();
''');
  }

  Future<void> _onPageLoaded() async {
    if (!mounted) return;
    await _applyFontSize();
    if (!mounted) return;
    await _injectSelectionStyles();
    if (!mounted) return;

    // No DOM elements injected — pill is a Flutter overlay so it's invisible
    // to WebView's selection hit-testing and cannot interfere with handles.
    await _controller.runJavaScript(r'''
(function() {
  if (window._ppSelSetup) return;
  window._ppSelSetup = true;
  window._ppPillShown = false;
  var _selTimer;
  document.addEventListener('selectionchange', function() {
    clearTimeout(_selTimer);
    _selTimer = setTimeout(function() {
      var sel = window.getSelection();
      var text = sel ? sel.toString().trim() : '';
      if (!text) {
        if (window._ppPillShown) {
          window._ppPillShown = false;
          window.SelectionHandler.postMessage(JSON.stringify({action:'hide_pill'}));
        }
        return;
      }
      try {
        var range = sel.getRangeAt(0);
        window._ppRange = range.cloneRange();
        var sentence = text;
        try { sentence = (range.startContainer.textContent || text).trim().substring(0,500); } catch(_) {}
        window._ppPillShown = true;
        window.SelectionHandler.postMessage(JSON.stringify({
          action:'show_pill', text:text, sentence:sentence
        }));
      } catch(_) { window._ppRange = null; }
    }, 150);
  });
})();
''');

    if (!mounted) return;

    // Wraps each text-node slice inside a range in its own coloured span.
    // This preserves inline markup (links, italics) and handles cross-element
    // selections — unlike surroundContents which throws on non-text boundaries
    // and the extractContents fallback which rebuilds the subtree.
    //
    // restoreHighlight walks the DOM, concatenates all visible text while
    // tracking node offsets, searches the concatenated string for the saved
    // text, and maps the match back to a Range. This works across <b>/<a>/etc.
    // boundaries where window.find() gives inconsistent results.
    await _controller.runJavaScript(r'''
function _ppSpan(color, type) {
  var s = document.createElement('span');
  s.className = '_pp_hl';
  var style = 'border-radius:2px;padding:0 1px;display:inline;';
  if (type === 'underline') {
    style += 'text-decoration-line:underline !important;text-decoration-color:' + color + ' !important;text-decoration-thickness:2px !important;';
  } else if (type === 'strikethrough') {
    style += 'text-decoration-line:line-through !important;text-decoration-color:' + color + ' !important;text-decoration-thickness:2px !important;';
  } else if (type === 'squiggly') {
    style += 'text-decoration-line:underline !important;text-decoration-style:wavy !important;text-decoration-color:' + color + ' !important;';
  } else {
    style += 'background:' + color + ' !important;';
  }
  s.setAttribute('style', style);
  return s;
}
function _ppWrapRange(range, color, type) {
  if (range.collapsed) return;
  // Single text node — safe to surroundContents.
  if (range.startContainer === range.endContainer &&
      range.startContainer.nodeType === 3) {
    try { range.surroundContents(_ppSpan(color, type)); return; } catch(e) {}
  }
  // Multi-node: walk text nodes inside the range and wrap each slice.
  var start = range.startContainer, startOff = range.startOffset;
  var end = range.endContainer, endOff = range.endOffset;
  var walker = document.createTreeWalker(
    range.commonAncestorContainer, NodeFilter.SHOW_TEXT, null, false);
  var nodes = [], n;
  while ((n = walker.nextNode())) {
    if (range.intersectsNode(n)) nodes.push(n);
  }
  for (var i = 0; i < nodes.length; i++) {
    var node = nodes[i];
    var a = (node === start) ? startOff : 0;
    var b = (node === end) ? endOff : node.nodeValue.length;
    if (b <= a) continue;
    var sub = document.createRange();
    try { sub.setStart(node, a); sub.setEnd(node, b); } catch(e) { continue; }
    try { sub.surroundContents(_ppSpan(color, type)); } catch(e) {}
  }
}
function applyAnnotation(color, type) {
  var range = window._ppRange;
  if (!range) return;
  _ppWrapRange(range, color, type || 'highlight');
  window._ppRange = null;
  var sel = window.getSelection();
  if (sel) sel.removeAllRanges();
}
function _ppCollectText() {
  var walker = document.createTreeWalker(
    document.body, NodeFilter.SHOW_TEXT, {
      acceptNode: function(n) {
        var p = n.parentElement;
        if (!p) return NodeFilter.FILTER_REJECT;
        var tag = p.tagName;
        if (tag === 'SCRIPT' || tag === 'STYLE' || tag === 'NOSCRIPT') {
          return NodeFilter.FILTER_REJECT;
        }
        return NodeFilter.FILTER_ACCEPT;
      }
    }, false);
  var nodes = [], starts = [], full = '';
  var n;
  while ((n = walker.nextNode())) {
    starts.push(full.length);
    nodes.push(n);
    full += n.nodeValue;
  }
  return { nodes: nodes, starts: starts, full: full };
}
function _ppNodeAt(starts, offset) {
  // Binary search: largest starts[i] <= offset.
  var lo = 0, hi = starts.length - 1, ans = 0;
  while (lo <= hi) {
    var mid = (lo + hi) >> 1;
    if (starts[mid] <= offset) { ans = mid; lo = mid + 1; }
    else hi = mid - 1;
  }
  return ans;
}
function restoreHighlight(text, color, type) {
  if (!text) return;
  var data = _ppCollectText();
  // Try exact match first, then whitespace-normalized.
  var idx = data.full.indexOf(text);
  var matched = text;
  if (idx < 0) {
    // Also strip soft hyphens (U+00AD) which ArXiv injects for line-breaking
    // but which sel.toString() omits from the selected text.
    var norm = text.replace(/[\s­]+/g, ' ').trim();
    if (norm !== text) {
      idx = data.full.indexOf(norm);
      matched = norm;
    }
  }
  if (idx < 0) return;
  var endIdx = idx + matched.length;
  var si = _ppNodeAt(data.starts, idx);
  var ei = _ppNodeAt(data.starts, endIdx - 1);
  var startOff = idx - data.starts[si];
  var endOff = endIdx - data.starts[ei];
  var range = document.createRange();
  try {
    range.setStart(data.nodes[si], startOff);
    range.setEnd(data.nodes[ei], endOff);
  } catch(e) { return; }
  _ppWrapRange(range, color, type || 'highlight');
}
''');

    if (!mounted) return;

    final highlights = ref.read(highlightProvider).where(
          (h) => h.paperId == widget.paper.id && h.readerType == 'html',
        );
    for (final h in highlights) {
      final alpha = h.annotationType == 'highlight' ? 0.6 : 0.9;
      final color = _hexToRgba(h.color, alpha);
      if (color == null) continue;
      await _controller.runJavaScript(
        "restoreHighlight(${jsonEncode(h.textContent)}, ${jsonEncode(color)}, ${jsonEncode(h.annotationType)});",
      );
      if (!mounted) return;
    }

    if (!mounted) return;

    if (widget.initialSearchText != null) {
      // Use the same cross-node concatenated search as restoreHighlight so
      // sentences spanning multiple ltx_text spans are found correctly.
      await _controller.runJavaScript('''
(function() {
  var target = ${jsonEncode(widget.initialSearchText)};
  var data = _ppCollectText();
  var idx = data.full.indexOf(target);
  if (idx < 0) {
    var norm = target.replace(/[\\s\\u00AD]+/g, ' ').trim();
    if (norm !== target) idx = data.full.indexOf(norm);
  }
  if (idx < 0) return;
  var node = data.nodes[_ppNodeAt(data.starts, idx)];
  if (node && node.parentElement) {
    node.parentElement.scrollIntoView({behavior: 'smooth', block: 'center'});
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

  void _showAnnotationPicker(BuildContext context) {
    if (_pendingSelection == null) return;
    String selectedType = 'highlight';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paperWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Annotation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final (type, icon, label) in _kAnnotationTypes)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheet(() => selectedType = type),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedType == type
                                ? AppColors.sageGreen.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: selectedType == type
                                  ? AppColors.sageGreen
                                  : AppColors.lightGray,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                icon,
                                size: 18,
                                color: selectedType == type
                                    ? AppColors.sageDark
                                    : AppColors.midGray,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: selectedType == type
                                      ? AppColors.sageDark
                                      : AppColors.midGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Colour',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _highlightColors.map((hexColor) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(sheetCtx).pop();
                      await _saveHighlight(hexColor, selectedType);
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
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  Future<void> _saveHighlight(String selectedHexColor, String type) async {
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
      annotationType: type,
      createdAt: DateTime.now(),
    );
    ref.read(highlightProvider.notifier).addHighlight(h);

    final alpha = type == 'highlight' ? 0.6 : 0.9;
    final rgba = _hexToRgba(selectedHexColor, alpha);
    if (rgba != null) {
      await _controller.runJavaScript(
        "applyAnnotation(${jsonEncode(rgba)}, ${jsonEncode(type)});",
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
            color: AppColors.inkBlack,
            tooltip: 'Decrease font size',
            onPressed: _fontSize > _minFontSize
                ? () => _changeFontSize(-_fontSizeStep)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            color: AppColors.inkBlack,
            tooltip: 'Increase font size',
            onPressed: _fontSize < _maxFontSize
                ? () => _changeFontSize(_fontSizeStep)
                : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_pillRect != null) _buildPillOverlay(),
        ],
      ),
    );
  }
}
