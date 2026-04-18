import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';

class StreakPopup extends StatefulWidget {
  const StreakPopup({required this.streakCount, super.key});

  final int streakCount;

  /// Show the popup. Returns a Future that completes when the user dismisses.
  static Future<void> show(BuildContext context, int streakCount) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => StreakPopup(streakCount: streakCount),
    );
  }

  @override
  State<StreakPopup> createState() => _StreakPopupState();
}

class _StreakPopupState extends State<StreakPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final String _message;

  static const _messages = [
    "Your curiosity is unstoppable.",
    "Science doesn't sleep, and neither does your streak.",
    "Another day, another frontier crossed.",
    "The best researchers show up every day.",
    "Knowledge compounds. So does your streak.",
    "You're building a habit that matters.",
    "Keep going — breakthroughs reward consistency.",
  ];

  @override
  void initState() {
    super.initState();
    _message = _messages[Random().nextInt(_messages.length)];
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _fireColor() {
    final n = widget.streakCount;
    if (n <= 1) return const Color(0xFFFFC107); // amber
    if (n == 2) return const Color(0xFFFF9800); // orange
    if (n == 3) return const Color(0xFFFF5722); // orange-red
    if (n == 4) return const Color(0xFFF44336); // red
    if (n == 5) return const Color(0xFFE53935); // crimson
    if (n == 6) return const Color(0xFFC62828); // deep red
    if (n == 7) return const Color(0xFFB71C1C); // saturated red
    // 8+: rainbow cycling (skip red, yellow, orange)
    const rainbow = [
      Color(0xFF9C27B0), // purple
      Color(0xFF2196F3), // blue
      Color(0xFF4CAF50), // green
      Color(0xFF3F51B5), // indigo
      Color(0xFFAB47BC), // violet
      Color(0xFF009688), // teal
    ];
    return rainbow[(n - 8) % 6];
  }

  double _lottieSpeed() {
    final n = widget.streakCount;
    if (n <= 1) return 0.6;
    if (n == 2) return 0.8;
    if (n == 3) return 1.0;
    if (n == 4) return 1.2;
    if (n == 5) return 1.4;
    if (n == 6) return 1.6;
    return 1.8;
  }

  @override
  Widget build(BuildContext context) {
    final color = _fireColor();
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: AppColors.inkBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            child: Lottie.asset(
              'assets/lottie/fire.json',
              controller: _controller,
              width: 120,
              height: 120,
              onLoaded: (composition) {
                final speed = _lottieSpeed();
                _controller.duration = Duration(
                  milliseconds:
                      (composition.duration.inMilliseconds / speed).round(),
                );
                _controller.repeat();
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.streakCount}-day streak!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.paperWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.paperWhite.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.inkBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Keep it up',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
