import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class HeroScreen extends StatelessWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.paperWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Hero Typography
              Text(
                    'PaperPulse',
                    style: const TextStyle(
                      fontFamily: 'DreamOrphans',
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkBlack,
                      height: 1.1,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 24),

              // Subtitle
              Text(
                    'Academic research, curated daily.\nUncover the knowledge that shapes the future.',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.midGray,
                      height: 1.3,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .slideY(begin: 0.1, end: 0, delay: 400.ms, duration: 800.ms),

              const Spacer(flex: 2),

              // Value Proposition Icons/Mini-features
              _buildFeatureRow(
                icon: Icons.auto_awesome,
                text: 'AI-Summarized Insights',
                theme: theme,
              ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.05),

              const SizedBox(height: 16),

              _buildFeatureRow(
                icon: Icons.history_edu,
                text: 'Curated to your interests',
                theme: theme,
              ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.05),

              const SizedBox(height: 16),

              _buildFeatureRow(
                icon: Icons.timer,
                text: '5 minutes a day',
                theme: theme,
              ).animate().fadeIn(delay: 1200.ms).slideX(begin: 0.05),

              const Spacer(),

              // Call to Action
              ElevatedButton(
                    onPressed: () => context.go('/onboarding/interests'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inkBlack,
                      foregroundColor: AppColors.paperWhite,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 1600.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.sageDark, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.inkBlack,
          ),
        ),
      ],
    );
  }
}
