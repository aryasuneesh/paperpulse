import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user.dart';
import '../../../services/digest_notification_service.dart';
import '../../../services/lab_notification_service.dart'
    show requestNotificationPermission;

class DigestScheduleScreen extends StatefulWidget {
  const DigestScheduleScreen({super.key});

  @override
  State<DigestScheduleScreen> createState() => _DigestScheduleScreenState();
}

class _DigestScheduleScreenState extends State<DigestScheduleScreen> {
  DigestDay _selectedDay = DigestDay.mon;
  DigestTime _selectedTime = DigestTime.morning;
  bool _saving = false;

  Future<void> _onContinue() async {
    setState(() => _saving = true);
    try {
      await requestNotificationPermission();
      await saveAndScheduleDigest(_selectedDay, _selectedTime);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (mounted) context.push('/onboarding/preview');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'When do you read?',
                style: theme.textTheme.headlineLarge,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 48),

              SegmentedButton<DigestDay>(
                segments: const [
                  ButtonSegment(value: DigestDay.mon, label: Text('Mon')),
                  ButtonSegment(value: DigestDay.wed, label: Text('Wed')),
                  ButtonSegment(value: DigestDay.fri, label: Text('Fri')),
                ],
                selected: {_selectedDay},
                onSelectionChanged: (s) =>
                    setState(() => _selectedDay = s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sageGreen,
                  selectedForegroundColor: AppColors.inkBlack,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),

              SegmentedButton<DigestTime>(
                segments: const [
                  ButtonSegment(
                      value: DigestTime.morning, label: Text('Morning')),
                  ButtonSegment(
                      value: DigestTime.evening, label: Text('Evening')),
                ],
                selected: {_selectedTime},
                onSelectionChanged: (s) =>
                    setState(() => _selectedTime = s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sageGreen,
                  selectedForegroundColor: AppColors.inkBlack,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 48),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your digest lands every ${_selectedDay.name.toUpperCase()} ${_selectedTime.name}.',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        color: AppColors.sageDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can always change this in settings',
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ElevatedButton(
                  onPressed: _saving ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
