import 'package:flutter/material.dart';

import '../theme/softinsa_theme.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.onSettingsTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 0),
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: SoftinsaColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: SoftinsaColors.border),
          boxShadow: SoftinsaShadows.soft,
        ),
        child: Row(
          children: [
            _ActionIconButton(
              icon: Icons.settings_outlined,
              onTap: onSettingsTap,
            ),
            const SizedBox(width: 8),
            _ActionIconButton(
              icon: Icons.notifications_none_outlined,
              onTap: onNotificationsTap,
            ),
            const Spacer(),
            Column(
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
                SizedBox(height: 2),
                Text(
                  'Badges Platform',
                  style: TextStyle(
                    fontSize: 11,
                    color: SoftinsaColors.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _ActionIconButton(
              icon: Icons.chat_bubble_outline,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEAF2FF),
                child: const Icon(Icons.person, size: 20, color: SoftinsaColors.blueDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        splashRadius: 22,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF5F9FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 22, color: SoftinsaColors.ink),
      ),
    );
  }
}
