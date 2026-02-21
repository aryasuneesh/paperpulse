import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class AccountCreationScreen extends StatelessWidget {
  const AccountCreationScreen({super.key});

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
              Text('Last step.', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Create your account to save your digest.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.midGray,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 64),

              // Email field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.midGray,
                  ),
                  filled: true,
                  fillColor: AppColors.paperWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.sageDark),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Password field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.midGray,
                  ),
                  filled: true,
                  fillColor: AppColors.paperWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.sageDark),
                  ),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  // Finalize onboarding, go to Digest
                  context.go('/digest');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Account'),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: AppColors.lightGray),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: theme.textTheme.labelSmall),
                  ),
                  Expanded(
                    child: Container(height: 1, color: AppColors.lightGray),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () {
                  // Google auth placeholder
                  context.go('/digest');
                },
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: AppColors.inkBlack,
                ),
                label: Text(
                  'Continue with Google',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.inkBlack,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.lightGray),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
