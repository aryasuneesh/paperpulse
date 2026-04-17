import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class InterestPickerScreen extends StatefulWidget {
  const InterestPickerScreen({super.key});

  @override
  State<InterestPickerScreen> createState() => _InterestPickerScreenState();
}

class _InterestPickerScreenState extends State<InterestPickerScreen> {
  // Topics reflect the actual HuggingFace Daily Papers catalogue (ML/AI domain)
  final List<String> _suggestedTopics = [
    'Machine Learning',
    'Computer Vision',
    'Language Models',
    'Generative AI',
    'Robotics',
    'Reinforcement Learning',
    'Multimodal AI',
    'Audio & Speech',
    'AI Safety',
    'Neural Networks',
    'Graph Learning',
    'AI Research',
  ];

  final Set<String> _selectedTopics = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isButtonEnabled = _selectedTopics.length >= 3;
    final fromProfile = GoRouterState.of(context).uri.queryParameters['from'] == 'profile';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What moves you?',
                style: theme.textTheme.headlineLarge,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 8),
              Text(
                    'Pick at least 3 topics. We\'ll curate your first digest.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.midGray,
                      fontSize: 15,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _suggestedTopics.length,
                  itemBuilder: (context, index) {
                    final topic = _suggestedTopics[index];
                    final isSelected = _selectedTopics.contains(topic);

                    return _TopicTile(
                          topic: topic,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedTopics.remove(topic);
                              } else {
                                _selectedTopics.add(topic);
                              }
                            });
                          },
                        )
                        .animate()
                        .fadeIn(delay: (300 + (index * 50)).ms)
                        .scale(
                          delay: (300 + (index * 50)).ms,
                          begin: const Offset(0.9, 0.9),
                        );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          if (fromProfile) {
                            context.pop();
                          } else {
                            context.push('/onboarding/schedule');
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isButtonEnabled
                        ? AppColors.sageGreen
                        : AppColors.lightGray,
                    foregroundColor: isButtonEnabled
                        ? AppColors.inkBlack
                        : AppColors.midGray,
                  ),
                  child: const Text('Build My Digest →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  final String topic;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sageLight : AppColors.paperWhite,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.sageDark : AppColors.lightGray,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.tag, // Placeholder icon
              size: 16,
              color: isSelected ? AppColors.sageDark : AppColors.midGray,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                topic,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? AppColors.inkBlack : AppColors.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 16, color: AppColors.sageDark),
          ],
        ),
      ),
    );
  }
}
