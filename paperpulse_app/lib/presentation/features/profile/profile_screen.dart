import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Container(
                color: AppColors.inkBlack,
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.sageGreen,
                          child: Text(
                            'AZ',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.inkBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alex Zen',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: AppColors.paperWhite,
                                ),
                              ),
                              Text(
                                'Joined Feb 2024',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.midGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '12',
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: AppColors.sageGreen,
                                fontSize: 48,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            Text(
                              'DAY STREAK',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: 'Geist Mono',
                                color: AppColors.sageGreen,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCol('42', 'PAPERS READ', theme),
                    _buildStatCol('8', 'TOPICS EXPLORED', theme),
                    _buildStatCol('112', 'HIGHLIGHTS', theme),
                  ],
                ),
              ),

              const Divider(color: AppColors.lightGray, height: 1),

              // Interest Radar Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Reading Focus',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTopicBar('Machine Learning', 0.8),
                    const SizedBox(height: 12),
                    _buildTopicBar('Neuroscience', 0.6),
                    const SizedBox(height: 12),
                    _buildTopicBar('Biology', 0.3),
                  ],
                ),
              ),

              const Divider(color: AppColors.lightGray, height: 1),

              // Settings Sections
              _buildSettingsTile(
                'Digest Schedule',
                Icons.calendar_today,
                theme,
                onTap: () => _showScheduleModal(context, theme),
              ),
              _buildSettingsTile(
                'Interest Topics',
                Icons.tag,
                theme,
                onTap: () {},
              ),
              _buildSettingsTile(
                'Notifications',
                Icons.notifications_outlined,
                theme,
                onTap: () {},
              ),
              _buildSettingsTile(
                'Account',
                Icons.person_outline,
                theme,
                onTap: () {},
              ),
              _buildSettingsTile(
                'Pro Subscription',
                Icons.star_border,
                theme,
                isPro: true,
                onTap: () {},
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String number, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          number,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 28,
            color: AppColors.inkBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: 'Geist Mono',
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicBar(String topic, double fillPercent) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            topic,
            style: const TextStyle(fontSize: 13, color: AppColors.darkGray),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fillPercent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    ThemeData theme, {
    bool isPro = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.inkBlack),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isPro
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sageLight,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'PRO',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'Geist Mono',
                  color: AppColors.sageDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right, color: AppColors.midGray),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  void _showScheduleModal(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paperWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Digest Schedule', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'When would you like to receive your digest?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.midGray,
                ),
              ),
              const SizedBox(height: 32),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Mon', label: Text('Mon')),
                  ButtonSegment(value: 'Wed', label: Text('Wed')),
                  ButtonSegment(value: 'Fri', label: Text('Fri')),
                ],
                selected: const {'Mon'},
                onSelectionChanged: (set) {},
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sageGreen,
                  selectedForegroundColor: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Morning', label: Text('Morning')),
                  ButtonSegment(value: 'Evening', label: Text('Evening')),
                ],
                selected: const {'Morning'},
                onSelectionChanged: (set) {},
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sageGreen,
                  selectedForegroundColor: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.inkBlack,
                  foregroundColor: AppColors.paperWhite,
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        );
      },
    );
  }
}
