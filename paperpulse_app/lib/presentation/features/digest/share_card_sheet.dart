import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/share_paper_card.dart';

enum _CardTheme { dark, light, sage }

class ShareCardSheet extends StatefulWidget {
  const ShareCardSheet({required this.paper, this.highlightText, super.key});

  final Paper paper;
  final String? highlightText;

  static void show(BuildContext context, Paper paper, {String? highlightText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareCardSheet(paper: paper, highlightText: highlightText),
    );
  }

  @override
  State<ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<ShareCardSheet> {
  _CardTheme _selectedTheme = _CardTheme.dark;
  bool _isExporting = false;
  final _cardKey = GlobalKey<SharePaperCardState>();

  Color get _bgColor => switch (_selectedTheme) {
        _CardTheme.dark => AppColors.inkBlack,
        _CardTheme.light => AppColors.paperWhite,
        _CardTheme.sage => AppColors.sageLight,
      };

  Color get _textColor => switch (_selectedTheme) {
        _CardTheme.dark => AppColors.paperWhite,
        _CardTheme.light => AppColors.inkBlack,
        _CardTheme.sage => AppColors.inkBlack,
      };

  Future<Uint8List?> _captureCard() async {
    // Wait one frame to ensure the widget is fully painted
    await Future.delayed(Duration.zero);
    final img = await _cardKey.currentState?.captureImage();
    if (img == null) return null;
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _share() async {
    setState(() => _isExporting = true);
    try {
      final bytes = await _captureCard();
      if (bytes == null) throw Exception('Failed to capture card');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/paperpulse_share.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: '📖 ${widget.paper.title}\n\nvia PaperPulse',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _copyLink() async {
    final url = widget.paper.sourceUrl;
    await Share.share(url, subject: widget.paper.title);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paperWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Let the sheet scroll on small devices
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('Share Paper', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Choose a style and share with your network.',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: AppColors.midGray),
            ),
            const SizedBox(height: 24),

            // Card preview — centred, never overflows
            Center(
              child: SharePaperCard(
                key: _cardKey,
                paper: widget.paper,
                customQuote: widget.highlightText,
                backgroundColor: _bgColor,
                textColor: _textColor,
              ),
            ),

            const SizedBox(height: 20),

            // Theme selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ThemeOption(
                  label: 'Dark',
                  bgColor: AppColors.inkBlack,
                  textColor: AppColors.paperWhite,
                  isSelected: _selectedTheme == _CardTheme.dark,
                  onTap: () => setState(() => _selectedTheme = _CardTheme.dark),
                ),
                const SizedBox(width: 12),
                _ThemeOption(
                  label: 'Light',
                  bgColor: AppColors.paperWhite,
                  textColor: AppColors.inkBlack,
                  isSelected: _selectedTheme == _CardTheme.light,
                  onTap: () =>
                      setState(() => _selectedTheme = _CardTheme.light),
                ),
                const SizedBox(width: 12),
                _ThemeOption(
                  label: 'Sage',
                  bgColor: AppColors.sageLight,
                  textColor: AppColors.inkBlack,
                  isSelected: _selectedTheme == _CardTheme.sage,
                  onTap: () => setState(() => _selectedTheme = _CardTheme.sage),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Share Image — full width
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _share,
              icon: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.inkBlack,
                      ),
                    )
                  : const Icon(Icons.ios_share),
              label: Text(_isExporting ? 'Preparing...' : 'Share Image'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24),
                backgroundColor: AppColors.inkBlack,
                foregroundColor: AppColors.paperWhite,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            // Share Link — full width
            OutlinedButton.icon(
              onPressed: _copyLink,
              icon: const Icon(Icons.link),
              label: const Text('Share Paper Link'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 24),
                side: const BorderSide(color: AppColors.lightGray),
                foregroundColor: AppColors.inkBlack,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color bgColor;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.sageDark : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
