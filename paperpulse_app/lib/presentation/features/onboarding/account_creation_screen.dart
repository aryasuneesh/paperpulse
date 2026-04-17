import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/user_migration_service.dart';
import 'splash_screen.dart' show onboardingCompleteKey;

const _deviceUuidKey = 'paperpulse_device_uuid';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = google_sign_in.GoogleSignIn.instance;
      await googleSignIn.initialize(serverClientId: AppConfig.googleWebClientId);
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'No ID token returned by Google.';

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final supabaseUid = Supabase.instance.client.auth.currentUser!.id;
      final prefs = await SharedPreferences.getInstance();
      final deviceUuid = prefs.getString(_deviceUuidKey) ?? '';

      await UserMigrationService.migrateIfNeeded(
        prefs: prefs,
        fromUserId: deviceUuid,
        toUserId: supabaseUid,
      );

      await prefs.setBool(onboardingCompleteKey, true);

      if (mounted) context.go('/digest');
    } catch (error) {
      debugPrint('Google sign-in error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sign-in failed. Please try again.',
              style: TextStyle(color: AppColors.inkBlack),
            ),
            backgroundColor: AppColors.sageLight,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
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
              Text('Last step.', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Save your reading progress.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.midGray,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 64),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.sageDark,
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Icon(
                        Icons.g_mobiledata,
                        size: 24,
                        color: theme.colorScheme.onSurface,
                      ),
                      label: Text(
                        'Continue with Google',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: AppColors.lightGray)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: theme.textTheme.labelSmall),
                  ),
                  Expanded(child: Container(height: 1, color: AppColors.lightGray)),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _isLoading ? null : _continueAsGuest,
                child: Text(
                  'Continue as Guest',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your data stays on this device only.',
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
