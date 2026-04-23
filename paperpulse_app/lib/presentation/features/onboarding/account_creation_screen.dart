import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import 'splash_screen.dart' show onboardingCompleteKey;

/// Final onboarding step. In the beta, PaperPulse has no cloud accounts —
/// identity is scoped to the device. This screen confirms the user is ready
/// to start reading and marks onboarding complete.
class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  bool _isLoading = false;

  Future<void> _startReading() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(onboardingCompleteKey, true);
      if (mounted) context.go('/digest');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              Text("You're all set.", style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Your reading stays on this device. No account, no tracking.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.midGray,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 64),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.sageDark,
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _startReading,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.inkBlack,
                    foregroundColor: AppColors.paperWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Start Reading',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.paperWhite,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'You can delete all your data any time from Profile → Account.',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.midGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
