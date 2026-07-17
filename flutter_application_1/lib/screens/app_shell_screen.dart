import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/achievement_center.dart';
import '../services/preload_service.dart';
import '../theme/softinsa_theme.dart';
import '../widgets/achievement_unlock_dialog.dart';
import 'badge_request_screen.dart';
import 'badges_screen.dart';
import 'dashboard_screen.dart';
import 'learning_path_screen.dart';
import 'more_options_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({
    super.key,
    this.initialIndex = 0,
    this.badgeRequestInitialStatuses,
  });

  final int initialIndex;
  final Set<BadgeRequestStatus>? badgeRequestInitialStatuses;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> with WidgetsBindingObserver {
  late int _selectedIndex;
  late final StreamSubscription<AchievementUnlock> _achievementSub;
  final List<AchievementUnlock> _achievementQueue = [];
  bool _isShowingAchievement = false;
  final GlobalKey _badgesKey = GlobalKey();

  late final List<Widget> _pages = [
    const DashboardScreen(),
    BadgesScreen(key: _badgesKey),
    const LearningPathScreen(),
    BadgeRequestScreen(initialStatuses: widget.badgeRequestInitialStatuses),
    const MoreOptionsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedIndex = widget.initialIndex;
    _achievementSub = AchievementCenter.instance.stream.listen((achievement) {
      _achievementQueue.add(achievement);
      _showNextAchievement();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = AchievementCenter.instance.takePending();
      if (pending.isNotEmpty) {
        _achievementQueue.addAll(pending);
        _showNextAchievement();
      }
    });

    PreloadService.instance.preloadAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _achievementSub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBadgesForNewSpecials();
    }
  }

  void _checkBadgesForNewSpecials() {
    (_badgesKey.currentState as dynamic)?.checkNewSpecialBadges();
  }

  Future<void> _showNextAchievement() async {
    if (!mounted || _isShowingAchievement || _achievementQueue.isEmpty) {
      return;
    }

    _isShowingAchievement = true;
    final achievement = _achievementQueue.removeAt(0);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(achievement: achievement),
    );

    _isShowingAchievement = false;
    if (mounted && _achievementQueue.isNotEmpty) {
      _showNextAchievement();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoftinsaColors.surfaceAlt,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF7F9FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorColor: const Color(0xFFEAF2FF),
          height: 72,
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              _checkBadgesForNewSpecials();
            }
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          backgroundColor: Colors.white,
          height: 65,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_rounded),
              label: AppLocalizations.of(context)!.dashboardNav,
            ),
            NavigationDestination(
              icon: const Icon(Icons.workspace_premium_outlined),
              label: AppLocalizations.of(context)!.badgesNav,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              label: AppLocalizations.of(context)!.learningPathNav,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              label: AppLocalizations.of(context)!.requestsNav,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              label: AppLocalizations.of(context)!.moreNav,
            ),
          ],
        ),
      ),
    );
  }
}
