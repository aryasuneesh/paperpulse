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

      // Capture at 3x for high resolution
      return await boundary.toImage(pixelRatio: 3.0);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: The actual share card in production might want to be rendered
    // off-screen or within an InteractiveViewer for preview.
    // Here we define the visual layout for capturing.
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width:
            1080 /
            3, // Scaled down for screen viewing, but pixelRatio: 3.0 scales it up for export
        height: 1920 / 3, // Assuming Stories format (16:9)
        color: widget.backgroundColor,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSourceBadge(),
                Text(
                  'PaperPulse',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontSize: 18,
                    color: widget.textColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            if (widget.paper.topicTags.isNotEmpty) _buildTopicTag(),
            const SizedBox(height: 24),
            Text(
              widget.paper.title,
              style: TextStyle(
                fontFamily: 'Instrument Serif',
                fontSize: 36,
                color: widget.textColor,
                height: 1.1,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            Container(height: 1, color: AppColors.sageGreen),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.sageGreen, width: 4),
                ),
              ),
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '"${_getHookSummary()}"',
                style: TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  color: widget.textColor,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 32),
            Container(height: 1, color: AppColors.sageGreen),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '${_formatAuthors()}  •  ${widget.paper.publishedAt.year}',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: widget.textColor.withOpacity(0.7),
                    ),
                  ),
                ),
                // Placeholder for QR code
                Container(
                  width: 64,
                  height: 64,
                  color: Colors.white,
                  child: const Center(
                    child: Icon(Icons.qr_code_2, size: 48, color: Colors.black),
                  ),
                ),
              ],
            ),
            if (!widget.isPro) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'paperpulse.app',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: widget.textColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        widget.paper.source.name.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: widget.textColor,
        ),
      ),
    );
  }

  Widget _buildTopicTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        widget.paper.topicTags.first.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.sageDark,
          letterSpacing: 1.2,
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
    // Just a placeholder to get the first sentence or so of the hook
    final hook = widget.paper.curiosityHook;
    final dotIndex = hook.indexOf('.');
    if (dotIndex != -1 && dotIndex < 100) {
      return '${hook.substring(0, dotIndex)}.';
    }
    if (hook.length > 100) {
      return '${hook.substring(0, 100)}...';
    }
    return hook;
  }
}
