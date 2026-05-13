import 'package:flutter/material.dart';
import '../theme/softinsa_theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.onSettingsTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          _ActionIconButton(
            icon: Icons.settings_outlined,
            onTap: onSettingsTap,
          ),
        ],
      ),
      leadingWidth: 60,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'SOFTINSA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: SoftinsaColors.blue,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            'Badges Platform',
            style: TextStyle(
              fontSize: 10,
              color: SoftinsaColors.textMuted,
              letterSpacing: 0.4,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        _ActionIconButton(
          icon: Icons.notifications_none_outlined,
          onTap: onNotificationsTap,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onProfileTap,
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(Icons.person, size: 20, color: SoftinsaColors.blueDark),
          ),
        ),
        const SizedBox(width: 16),
      ],
      shape: const Border(
        bottom: BorderSide(color: SoftinsaColors.border, width: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 24, color: SoftinsaColors.ink),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 24,
    );
  }
}
