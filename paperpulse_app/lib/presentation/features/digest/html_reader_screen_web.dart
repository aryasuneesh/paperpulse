import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';

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
  late final String _viewType;

  String get _htmlUrl {
    final url = widget.paper.sourceUrl;
    return url.replaceAllMapped(
      RegExp(r'pdf/(.*)\.pdf$'),
      (m) => 'html/${m[1]}',
    );
  }

  @override
  void initState() {
    super.initState();
    _viewType = 'html-reader-${widget.paper.id}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.src = _htmlUrl;
      iframe.style.border = 'none';
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      iframe.allowFullscreen = true;
      return iframe;
    });
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
      ),
      body: HtmlElementView(viewType: _viewType),
    );
  }
}
