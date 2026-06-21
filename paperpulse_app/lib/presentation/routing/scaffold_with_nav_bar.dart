import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'app_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (
      icon: Icons.mail_outline,
      activeIcon: Icons.mail,
      label: 'Digest',
    ),
    (
      icon: Icons.search,
      activeIcon: Icons.search,
      label: 'Browse',
    ),
    (
      icon: Icons.bookmark_outline,
      activeIcon: Icons.bookmark,
      label: 'Library',
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return isWide ? _wideLayout(context) : _narrowLayout(context);
      },
    );
  }

  Widget _wideLayout(BuildContext context) {
    final theme = Theme.of(context);
    final idx = navigationShell.currentIndex;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: idx,
            onDestinationSelected: (i) => _onTap(context, i),
            labelType: NavigationRailLabelType.selected,
            backgroundColor:
                theme.brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A)
                    : AppColors.paperWhite,
            selectedIconTheme: const IconThemeData(color: AppColors.sageDark),
            selectedLabelTextStyle: const TextStyle(
              color: AppColors.sageDark,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedIconTheme: IconThemeData(color: AppColors.midGray),
            unselectedLabelTextStyle: TextStyle(
              color: AppColors.midGray,
              fontSize: 12,
            ),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'PP',
                style: TextStyle(
                  fontFamily: 'DreamOrphans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color:
                      theme.brightness == Brightness.dark
                          ? AppColors.paperWhite
                          : AppColors.inkBlack,
                ),
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  Widget _narrowLayout(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => _onTap(context, i),
        items: [
          for (final d in _destinations)
            BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(
                d.activeIcon,
                color: d.label == 'Browse' ? AppColors.sageGreen : null,
              ),
              label: d.label,
            ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index == navigationShell.currentIndex) {
      GlobalKey<NavigatorState>? currentKey;
      switch (index) {
        case 0:
          currentKey = shellNavigatorDigestKey;
        case 1:
          currentKey = shellNavigatorBrowseKey;
        case 2:
          currentKey = shellNavigatorLibraryKey;
        case 3:
          currentKey = shellNavigatorProfileKey;
      }
      currentKey?.currentState?.popUntil((route) => route.isFirst);
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
