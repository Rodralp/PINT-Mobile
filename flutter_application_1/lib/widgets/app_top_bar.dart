import 'package:flutter/material.dart';

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
      child: Row(
        children: [
          _ActionIconButton(
            icon: Icons.settings_outlined,
            onTap: onSettingsTap,
          ),
          const Spacer(),
          Image.asset(
            'assets/images/softinsa.png',
            width: 108,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                icon: Icons.notifications_none_outlined,
                onTap: onNotificationsTap,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onProfileTap,
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFC4CAD3),
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
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
        icon: Icon(icon, size: 34, color: const Color(0xFF111827)),
      ),
    );
  }
}
