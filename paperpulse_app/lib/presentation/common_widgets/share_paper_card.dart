import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';

class SharePaperCard extends StatefulWidget {
  const SharePaperCard({
    required this.paper,
    this.customQuote,
    this.backgroundColor = AppColors.inkBlack,
    this.textColor = AppColors.paperWhite,
    super.key,
  });

  final Paper paper;
  final String? customQuote;
  final Color backgroundColor;
  final Color textColor;

  /// Extracts as many complete sentences as fit within [maxChars], always
  /// filling as much space as possible. Falls back to a hard truncation.
  static String extractQuote(String text, {int maxChars = 520}) {
    final trimmed = text.trim();
    final parts = trimmed.split(RegExp(r'(?<=[.!?])\s+'));

    // Greedily append sentences while staying under the limit
    String result = '';
    for (final sentence in parts) {
      final candidate = result.isEmpty ? sentence : '$result $sentence';
      if (candidate.length <= maxChars) {
        result = candidate;
      } else {
        break;
      }
    }
    if (result.isNotEmpty) return result;

    // No complete sentence fit — hard-truncate at word boundary
    if (trimmed.length <= maxChars) return trimmed;
    final truncated = trimmed.substring(0, maxChars);
    final lastSpace = truncated.lastIndexOf(' ');
    return '${lastSpace > 0 ? truncated.substring(0, lastSpace) : truncated}...';
  }

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
            // Row 1: source badge + topic tag on same line, app name on right
            Row(
              children: [
                _buildSourceBadge(),
                const SizedBox(width: 8),
                if (widget.paper.topicTags.isNotEmpty) _buildTopicTag(),
                const Spacer(),
                Text(
                  'PaperPulse',
                  style: TextStyle(
                    fontFamily: 'DreamOrphans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.textColor.withOpacity(0.5),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Paper title — full title, smaller font
            Text(
              widget.paper.title,
              style: TextStyle(
                fontFamily: 'Instrument Serif',
                fontSize: 16,
                color: widget.textColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),

            Container(height: 1, color: AppColors.sageGreen),
            const SizedBox(height: 14),

            // Quote — highlight text (truncated to 1-2 sentences) or curiosity hook
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.sageGreen, width: 3),
                  ),
                ),
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '"${widget.customQuote != null ? SharePaperCard.extractQuote(widget.customQuote!) : widget.paper.curiosityHook}"',
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    height: 1.6,
                    color: widget.textColor.withOpacity(0.9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.sageGreen),
            const SizedBox(height: 12),

            // Footer: authors + QR code
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
                QrImageView(
                  data: widget.paper.sourceUrl,
                  version: QrVersions.auto,
                  size: 44,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
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
    final sageBackground = widget.backgroundColor == AppColors.sageLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: sageBackground ? Colors.transparent : AppColors.sageLight,
        borderRadius: BorderRadius.circular(100),
        border: sageBackground
            ? Border.all(color: Colors.white, width: 1)
            : null,
      ),
      child: Text(
        widget.paper.topicTags.first.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.sageDark,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _formatAuthors() {
    if (widget.paper.authors.isEmpty) return 'Unknown';
    if (widget.paper.authors.length == 1) return widget.paper.authors.first;
    return '${widget.paper.authors.first} et al.';
  }
}
