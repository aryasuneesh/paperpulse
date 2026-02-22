import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/onboarding/welcome');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.paperWhite,
      body: InkWell(
        onTap: () {
          context.go('/onboarding/welcome');
        },
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 64),
                    children: [
                      const TextSpan(
                        text: 'Paper',
                        style: TextStyle(color: AppColors.inkBlack),
                      ),
                      TextSpan(
                        text: 'Pulse',
                        style: TextStyle(
                          color: AppColors.sageGreen,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Read the research. Feed the curiosity.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.midGray,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
