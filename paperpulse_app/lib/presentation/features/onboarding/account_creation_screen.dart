import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';

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
      final webClientId =
          '100706126205-5ovpkkd6j58i3519gfktfooqdvset2gj.apps.googleusercontent.com';

      final googleSignIn = google_sign_in.GoogleSignIn.instance;
      await googleSignIn.initialize(serverClientId: webClientId);

      await googleSignIn.signOut();
      final googleUser = await googleSignIn.authenticate();
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // 2. Pass the ID token to Supabase Auth
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      // On success, go to digest
      if (mounted) {
        context.go('/digest');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Config error (Check SHA-1). Proceeding in Demo Mode.',
              style: TextStyle(color: AppColors.inkBlack),
            ),
            backgroundColor: AppColors.sageGreen,
          ),
        );
        // Fallback for MVP testing when external config fails
        context.go('/digest');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.sageDark,
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: _signInWithGoogle,
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
