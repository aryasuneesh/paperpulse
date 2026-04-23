import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/account_deletion_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user.dart';
import '../../../services/daily_paper_notification_service.dart';
import '../../../services/digest_notification_service.dart';
import '../../../services/digest_personalization_service.dart';
import '../../../data/models/bookmark.dart';
import '../digest/providers/personalized_digest_provider.dart';
import '../library/providers/bookmark_provider.dart';
import '../library/providers/highlight_provider.dart';
import 'highlights_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarks = ref.watch(bookmarkProvider);
    final highlights = ref.watch(highlightProvider);

    const displayName = 'Reader';

    final finishedPapersCount =
        bookmarks.where((b) => b.status == BookmarkStatus.finished).length;
    final topicsExploredCount =
        bookmarks.expand((b) => b.topicTags).toSet().length;
    final highlightCount = highlights.length;

    final topicCounts = <String, int>{};
    for (final b in bookmarks) {
      for (final tag in b.topicTags) {
        topicCounts[tag] = (topicCounts[tag] ?? 0) + 1;
      }
    }
    final sortedTopics = topicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTopics = sortedTopics.take(3).toList();
    final maxCount = topTopics.isNotEmpty ? topTopics.first.value : 1;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: AppColors.inkBlack,
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.sageGreen,
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.inkBlack,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.paperWhite,
                            ),
                          ),
                          Text(
                            'Local device only',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.midGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/library'),
                      child: _statCard(
                          '$finishedPapersCount', 'PAPERS READ', theme),
                    ),
                    _statCard('$topicsExploredCount', 'TOPICS EXPLORED', theme),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HighlightsScreen()),
                      ),
                      child: _statCard('$highlightCount', 'HIGHLIGHTS', theme),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.lightGray, height: 1),

              // Reading Focus
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Reading Focus',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    if (topTopics.isEmpty)
                      Text(
                        'Read more papers to see your reading focus.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.midGray),
                      )
                    else
                      ...topTopics.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _topicBar(entry.key, entry.value / maxCount, theme),
                          )),
                  ],
                ),
              ),

              const Divider(color: AppColors.lightGray, height: 1),

              // Menu items
              _tile('Digest Schedule', Icons.calendar_today, theme,
                  onTap: () => _showScheduleModal(context, theme, ref)),
              _tile('Interest Topics', Icons.tag, theme,
                  onTap: () => context.push('/onboarding/interests?from=profile')),
              _tile('Manage Labs', Icons.science_outlined, theme,
                  onTap: () => context.push('/labs')),
              _tile('Notifications', Icons.notifications_outlined, theme,
                  onTap: () => _showNotificationsSheet(context, theme)),
              _tile('Account', Icons.person_outline, theme,
                  onTap: () => _showAccountSheet(context, theme, displayName)),
              _tile('Buy Me a Coffee', Icons.coffee_outlined, theme,
                  onTap: () => _openBuyMeACoffee()),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String number, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sageLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sageGreen),
      ),
      child: Column(
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
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              letterSpacing: 0.5,
              color: AppColors.inkBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topicBar(String topic, double fillPercent, ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(topic,
              style: TextStyle(
                  fontSize: 13, color: theme.colorScheme.onSurface)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withValues(alpha: 0.5),
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

  Widget _tile(String title, IconData icon, ThemeData theme,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(title,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.midGray),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  void _showScheduleModal(
      BuildContext context, ThemeData theme, WidgetRef ref) async {
    final saved = await loadDigestSchedule();
    var selectedDay = saved?.$1 ?? DigestDay.mon;
    var selectedTime = saved?.$2 ?? DigestTime.morning;
    var digestSize = await loadDigestSize();
    var dailyEnabled = await loadDailyNotifEnabled();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Digest Schedule', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('When would you like to receive your digest?',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.midGray)),
              const SizedBox(height: 32),
              SegmentedButton<DigestDay>(
                segments: const [
                  ButtonSegment(value: DigestDay.mon, label: Text('Mon')),
                  ButtonSegment(value: DigestDay.wed, label: Text('Wed')),
                  ButtonSegment(value: DigestDay.fri, label: Text('Fri')),
                ],
                selected: {selectedDay},
                onSelectionChanged: (s) =>
                    setModalState(() => selectedDay = s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sageGreen,
                  selectedForegroundColor: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<DigestTime>(
                segments: const [
                  ButtonSegment(
                      value: DigestTime.morning, label: Text('Morning')),
                  ButtonSegment(
                      value: DigestTime.evening, label: Text('Evening')),
                ],
                selected: {selectedTime},
                onSelectionChanged: (s) =>
                    setModalState(() => selectedTime = s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sageGreen,
                  selectedForegroundColor: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 24),
              Text('Papers per digest: $digestSize',
                  style: theme.textTheme.labelMedium),
              Slider(
                value: digestSize.toDouble(),
                min: digestSizeMin.toDouble(),
                max: digestSizeMax.toDouble(),
                divisions: digestSizeMax - digestSizeMin,
                label: '$digestSize',
                onChanged: (v) =>
                    setModalState(() => digestSize = v.round()),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: dailyEnabled,
                onChanged: (v) => setModalState(() => dailyEnabled = v),
                title: const Text('Daily notifications'),
                subtitle: const Text(
                  'Notify me when new papers match my interests',
                  style: TextStyle(fontSize: 12),
                ),
                activeThumbColor: AppColors.sageDark,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  await saveAndScheduleDigest(selectedDay, selectedTime);
                  await saveDigestSize(digestSize);
                  await saveDailyNotifEnabled(dailyEnabled);
                  if (dailyEnabled) {
                    await ensureDailyPaperTaskRegistered();
                  } else {
                    await cancelDailyPaperTask();
                  }
                  ref.invalidate(digestSizeProvider);
                  nav.pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.inkBlack,
                  foregroundColor: AppColors.paperWhite,
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _NotificationsSheet(theme: theme),
    );
  }

  void _showAccountSheet(
    BuildContext context,
    ThemeData theme,
    String displayName,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Account', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'PaperPulse stores your reading history only on this device. '
              'No cloud account is created.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.midGray,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.sageLight,
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.sageDark,
                ),
              ),
              title: Text(displayName,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Local device only',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: AppColors.midGray),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Delete all my data'),
              onPressed: () => _confirmDelete(context, theme),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wipes bookmarks, highlights, reading history, and preferences. '
              'Cannot be undone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: AppColors.midGray),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently removes your bookmarks, highlights, '
          'reading history, interests, schedule, and caches from this '
          'device. You will be taken back to onboarding. This cannot '
          'be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(dialogContext);
              final rootNav = Navigator.of(context);
              final router = GoRouter.of(context);
              nav.pop();
              await AccountDeletionService.deleteEverything();
              if (rootNav.mounted) {
                rootNav.maybePop(); // dismiss the bottom sheet
              }
              router.go('/splash');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _openBuyMeACoffee() async {
    final uri = Uri.parse('https://buymeacoffee.com/paperpulse');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _NotificationsSheet extends StatefulWidget {
  final ThemeData theme;
  const _NotificationsSheet({required this.theme});

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    if (mounted) setState(() => _enabled = status.isGranted);
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (mounted) setState(() => _enabled = status.isGranted);
    } else {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Notifications', style: widget.theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Get notified when your digest is ready.',
            style: widget.theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.midGray),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Digest notifications',
                style: widget.theme.textTheme.bodyMedium),
            subtitle: Text(
              _enabled ? 'Notifications are on' : 'Notifications are off',
              style: widget.theme.textTheme.labelSmall
                  ?.copyWith(color: AppColors.midGray),
            ),
            value: _enabled,
            activeThumbColor: AppColors.sageDark,
            onChanged: _toggle,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
