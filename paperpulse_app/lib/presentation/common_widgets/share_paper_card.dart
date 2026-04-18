import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';

class SharePaperCard extends StatefulWidget {
  const SharePaperCard({
    required this.paper,
    required this.isPro,
    this.backgroundColor = AppColors.inkBlack,
    this.textColor = AppColors.paperWhite,
    super.key,
  });

  final Paper paper;
  final bool isPro;
  final Color backgroundColor;
  final Color textColor;

  @override
  State<SharePaperCard> createState() => SharePaperCardState();
}

class SharePaperCardState extends State<SharePaperCard> {
  final GlobalKey boundaryKey = GlobalKey();

  Future<ui.Image?> captureImage() async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;
      // 3× pixel ratio → 1080×1350 export (4:5 feed format)
      return await boundary.toImage(pixelRatio: 3.0);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display at 4:5 (360×450 logical px). Export at 3× = 1080×1350.
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: 360,
        height: 450,
        color: widget.backgroundColor,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row: source badge + wordmark
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSourceBadge(),
                Text(
                  'PaperPulse',
                  style: TextStyle(
                    fontFamily: 'DreamOrphans',
                    fontSize: 14,
                    color: widget.textColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Topic tag
            if (widget.paper.topicTags.isNotEmpty) ...[
              _buildTopicTag(),
              const SizedBox(height: 12),
            ],

            // Paper title — Instrument Serif
            Text(
              widget.paper.title,
              style: TextStyle(
                fontFamily: 'Instrument Serif',
                fontSize: 22,
                color: widget.textColor,
                height: 1.15,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            Container(height: 1, color: AppColors.sageGreen),
            const SizedBox(height: 16),

            // Hook quote — Quicksand
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.sageGreen, width: 3),
                  ),
                ),
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '"${_getHookSummary()}"',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    height: 1.6,
                    color: widget.textColor.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.sageGreen),
            const SizedBox(height: 12),

            // Footer: authors + QR placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '${_formatAuthors()}  •  ${widget.paper.publishedAt.year}',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      color: widget.textColor.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  color: Colors.white,
                  child: const Center(
                    child: Icon(Icons.qr_code_2, size: 36, color: Colors.black),
                  ),
                ),
              ],
            ),

            if (!widget.isPro) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'paperpulse.app',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 9,
                    color: widget.textColor.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: widget.textColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        widget.paper.source.name.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: widget.textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTopicTag() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.sageLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          widget.paper.topicTags.first.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.sageDark,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  String _formatAuthors() {
    if (widget.paper.authors.isEmpty) return 'Unknown';
    if (widget.paper.authors.length == 1) return widget.paper.authors.first;
    return '${widget.paper.authors.first} et al.';
  }

  String _getHookSummary() {
    final hook = widget.paper.curiosityHook;
    // First 2 sentences or 180 chars, whichever is shorter
    final secondDot = _nthDot(hook, 2);
    if (secondDot != -1 && secondDot < 180) {
      return hook.substring(0, secondDot + 1);
    }
    if (hook.length > 180) return '${hook.substring(0, 180)}…';
    return hook;
  }

  int _nthDot(String s, int n) {
    int count = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '.') {
        count++;
        if (count == n) return i;
      }
    }
    return -1;
  }
}
