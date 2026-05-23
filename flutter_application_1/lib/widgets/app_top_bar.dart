import 'package:flutter/material.dart';

import '../services/auth_session.dart';
import '../services/consultor_api.dart';
import '../theme/softinsa_theme.dart';

class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.onSettingsTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
    required this.onMessagesTap,
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onMessagesTap;

  @override
  State<AppTopBar> createState() => _AppTopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

class _AppTopBarState extends State<AppTopBar> {
  late final Future<String?> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadAvatarUrl();
  }

  Future<String?> _loadAvatarUrl() async {
    try {
      final accountId = await AuthSession.getAccountId();
      if (accountId == null || accountId <= 0) {
        return null;
      }

      final profile = await ConsultorApi.instance.fetchProfile(
        accountId: accountId,
      );

      final avatar = profile.avatar.trim();
      return avatar.isNotEmpty ? avatar : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _avatarFuture,
      builder: (context, snapshot) {
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leadingWidth: 132,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIconButton(
                  icon: Icons.settings_outlined,
                  onTap: widget.onSettingsTap,
                ),
                const SizedBox(width: 4),
                _ActionIconButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: widget.onMessagesTap,
                ),
              ],
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/softinsa.png',
                height: 28,
                fit: BoxFit.contain,
              ),
              const Text(
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
              onTap: widget.onNotificationsTap,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onProfileTap,
              child: _TopBarAvatar(avatarUrl: snapshot.data),
            ),
            const SizedBox(width: 16),
          ],
          shape: const Border(
            bottom: BorderSide(color: SoftinsaColors.border, width: 1),
          ),
        );
      },
    );
  }
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
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      splashRadius: 24,
    );
  }
}

class _TopBarAvatar extends StatelessWidget {
  const _TopBarAvatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        shape: BoxShape.circle,
      ),
      child: hasAvatar
          ? ClipOval(
              child: Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 20,
                  color: SoftinsaColors.blueDark,
                ),
              ),
            )
          : const Icon(Icons.person, size: 20, color: SoftinsaColors.blueDark),
    );
  }
}
