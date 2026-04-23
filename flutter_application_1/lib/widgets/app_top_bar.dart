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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                icon: Icons.settings_outlined,
                onTap: onSettingsTap,
              ),
              const SizedBox(width: 4),
              _ActionIconButton(
                icon: Icons.notifications_none_outlined,
                onTap: onNotificationsTap,
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'SOFTINSA',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                icon: Icons.chat_bubble_outline,
                onTap: () {}, // Por agora sem função específica
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onProfileTap,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images/profile_placeholder.png'), // Se não existir, o Flutter mostra o fallback
                  backgroundColor: Color(0xFFC4CAD3),
                  child: Icon(Icons.person, size: 20, color: Colors.white),
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
        icon: Icon(icon, size: 28, color: const Color(0xFF111827)),
      ),
    );
  }
}
